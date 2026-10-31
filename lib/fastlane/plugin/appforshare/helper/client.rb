require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Helper
    # Same resumable upload API as the website and the npm CLI: create, PUT chunks at offsets, complete, poll.
    class AppforshareClient
      class Error < StandardError; end

      def initialize(token:, api: 'https://appforshare.io', log: nil)
        @token = token
        @api = api.sub(%r{/+\z}, '')
        @log = log || ->(_msg) {}
      end

      def upload(path, notes: nil, channel: nil)
        size = File.size(path)
        body = { fileName: File.basename(path), size: size }
        body[:releaseNotes] = notes[0, 5000] if notes && !notes.empty?
        body[:channel] = channel if channel && !channel.empty?
        created = request(:post, '/uploads', json: body)
        @log.call("Uploading #{File.basename(path)} (#{format('%.1f', size / 1024.0 / 1024)} MB)")
        offset = created['offset'] || 0
        headers = { 'X-Upload-Token' => created['token'] }
        File.open(path, 'rb') do |f|
          while offset < size
            f.seek(offset)
            chunk = f.read([created['chunkBytes'], size - offset].min)
            res = request(:put, "/uploads/#{created['id']}?offset=#{offset}", body: chunk, headers: headers)
            offset = res['offset'].is_a?(Integer) ? res['offset'] : offset + chunk.bytesize
          end
        end
        request(:post, "/uploads/#{created['id']}/complete", headers: headers)
        deadline = Time.now + 20 * 60
        loop do
          s = request(:get, "/uploads/#{created['id']}", headers: headers)
          raise Error, (s['error'] || 'The build could not be processed.') if s['status'] == 'FAILED'
          if s['status'] == 'READY'
            # The channel is filled in right after the build is ready.
            5.times do
              break if body[:channel].nil? || s['channel']

              sleep 1
              s = request(:get, "/uploads/#{created['id']}", headers: headers)
            end
            return s
          end
          raise Error, 'Processing is taking too long. Check your dashboard.' if Time.now > deadline

          sleep 2
        end
      end

      def build(ref)
        request(:get, "/ci/builds/#{URI.encode_www_form_component(ref)}")
      end

      def request(method, path, json: nil, body: nil, headers: {})
        uri = URI("#{@api}/api#{path}")
        attempt = 0
        begin
          attempt += 1
          req = { get: Net::HTTP::Get, post: Net::HTTP::Post, put: Net::HTTP::Put, delete: Net::HTTP::Delete }[method].new(uri)
          req['Authorization'] = "Bearer #{@token}"
          req['User-Agent'] = "fastlane-plugin-appforshare/#{Fastlane::Appforshare::VERSION}"
          headers.each { |k, v| req[k] = v }
          if json
            req['Content-Type'] = 'application/json'
            req.body = JSON.generate(json)
          elsif body
            req['Content-Type'] = 'application/octet-stream'
            req.body = body
          end
          res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', read_timeout: 300) { |http| http.request(req) }
          data = res.body && !res.body.empty? ? (JSON.parse(res.body) rescue {}) : {}
          code = res.code.to_i
          raise IOError, "HTTP #{code}" if code >= 500 && attempt < 6
          offset_reply = code == 400 && data['offset'].is_a?(Integer)
          unless (200..299).cover?(code) || code == 409 || offset_reply
            msg = data['message'].is_a?(Array) ? data['message'].first : data['message']
            raise Error, (msg || "Request failed with #{code}")
          end
          data
        rescue IOError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
          raise Error, "Network error: #{e.message}" if attempt >= 6

          sleep [30, 2**attempt].min
          retry
        end
      end
    end
  end
end
