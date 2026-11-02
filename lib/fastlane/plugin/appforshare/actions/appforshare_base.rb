require 'fastlane/action'
require_relative '../helper/client'

module Fastlane
  module Helper
    # Options and client shared by the tester, group, UDID and latest build actions.
    module AppforshareShared
      def self.client(params)
        Helper::AppforshareClient.new(token: params[:api_token], api: params[:api_url], log: ->(m) { UI.message(m) })
      end

      # "a@x.com, b@y.com" or an array; a file with one per line or comma separated.
      def self.list(value, file = nil)
        items = Array(value).flat_map { |v| v.to_s.split(/[,\n\r]+/) }
        items += File.read(file).split(/[,\n\r]+/) if file && !file.empty?
        items.map(&:strip).reject(&:empty?)
      end

      def self.token_option
        FastlaneCore::ConfigItem.new(key: :api_token, env_name: 'APPFORSHARE_TOKEN', description: 'AppForShare API token (Dashboard, Settings)', sensitive: true, optional: false)
      end

      def self.api_option
        FastlaneCore::ConfigItem.new(key: :api_url, env_name: 'APPFORSHARE_API', description: 'API origin', optional: true, default_value: 'https://appforshare.io')
      end

      def self.project_option
        FastlaneCore::ConfigItem.new(key: :project, env_name: 'APPFORSHARE_PROJECT', description: 'Project id (appforshare builds --json shows it)', optional: true, type: Integer)
      end

      def self.emails_options
        [
          FastlaneCore::ConfigItem.new(key: :emails, env_name: 'APPFORSHARE_TESTERS', description: 'Tester emails, comma separated or an array', optional: true, type: Array),
          FastlaneCore::ConfigItem.new(key: :file, env_name: 'APPFORSHARE_TESTERS_FILE', description: 'File with tester emails, one per line or comma separated', optional: true)
        ]
      end
    end
  end
end
