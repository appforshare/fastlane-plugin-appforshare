require 'fastlane/action'
require_relative '../helper/client'

module Fastlane
  module Actions
    module SharedValues
      APPFORSHARE_URL = :APPFORSHARE_URL
      APPFORSHARE_SLUG = :APPFORSHARE_SLUG
      APPFORSHARE_READINESS = :APPFORSHARE_READINESS
      APPFORSHARE_CHANNEL_URL = :APPFORSHARE_CHANNEL_URL
    end

    class AppforshareAction < Action
      def self.run(params)
        file = params[:file]
        UI.user_error!('No build to upload. Pass file: or run gym / gradle first.') unless file && File.exist?(file)
        client = Helper::AppforshareClient.new(token: params[:api_token], api: params[:api_url], log: ->(m) { UI.message(m) })
        status = client.upload(file, notes: params[:release_notes], channel: params[:channel])
        readiness = 'unknown'
        findings = []
        begin
          detail = client.build(status['slug'])
          readiness = detail.dig('readinessReport', 'status') || 'unknown'
          findings = detail.dig('readinessReport', 'findings') || []
        rescue Helper::AppforshareClient::Error => e
          raise if params[:fail_on]

          UI.important("Store readiness not read: #{e.message}")
        end
        Actions.lane_context[SharedValues::APPFORSHARE_URL] = status['url']
        Actions.lane_context[SharedValues::APPFORSHARE_SLUG] = status['slug']
        Actions.lane_context[SharedValues::APPFORSHARE_READINESS] = readiness
        Actions.lane_context[SharedValues::APPFORSHARE_CHANNEL_URL] = status.dig('channel', 'url')
        UI.success("Install link: #{status['url']}")
        UI.success("Channel #{status['channel']['name']}: #{status['channel']['url']}") if status['channel']
        UI.important("Not put into channel #{params[:channel]}. Check the build page.") if params[:channel] && !status['channel']
        UI.message("Store readiness: #{readiness}")
        findings.each { |f| UI.important("[#{f['level']}] #{f['title']}: #{f['fix']}") }
        fail_on = params[:fail_on]
        if (fail_on == 'blocked' && readiness == 'blocked') || (fail_on == 'review' && %w[blocked review].include?(readiness))
          UI.user_error!("Store readiness is \"#{readiness}\" (fail_on: #{fail_on}). The build is uploaded and its link works: #{status['url']}")
        end
        status['url']
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Upload an .ipa or .apk to AppForShare and get an install link for testers'
      end

      def self.details
        'Uploads in 32 MB chunks (resumes after a dropped connection), waits until the build is ready, returns the ' \
          'install link and reads the store readiness check. Needs an AppForShare API token (Pro and Team plans).'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'The install link'
      end

      def self.output
        [
          ['APPFORSHARE_URL', 'Install link'],
          ['APPFORSHARE_SLUG', 'Share code of the build'],
          ['APPFORSHARE_READINESS', 'Store readiness status: ready, review, blocked or unknown'],
          ['APPFORSHARE_CHANNEL_URL', 'Stable link of the channel (with channel:), always the newest build in it']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token, env_name: 'APPFORSHARE_TOKEN', description: 'AppForShare API token (Dashboard, Settings)', sensitive: true, optional: false),
          FastlaneCore::ConfigItem.new(key: :file, env_name: 'APPFORSHARE_FILE', description: 'Path to the .ipa or .apk', optional: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :release_notes, env_name: 'APPFORSHARE_RELEASE_NOTES', description: 'Release notes shown to testers (Pro and Team)', optional: true),
          FastlaneCore::ConfigItem.new(key: :channel, env_name: 'APPFORSHARE_CHANNEL', description: 'Put the build into this channel (Beta, Live), created on first use (Pro and Team)', optional: true),
          FastlaneCore::ConfigItem.new(key: :fail_on, env_name: 'APPFORSHARE_FAIL_ON', description: 'Fail the lane when store readiness is "blocked", or "review"', optional: true,
                                       verify_block: proc { |v| UI.user_error!('fail_on takes "blocked" or "review"') unless %w[blocked review].include?(v) }),
          FastlaneCore::ConfigItem.new(key: :api_url, env_name: 'APPFORSHARE_API', description: 'API origin', optional: true, default_value: 'https://appforshare.io')
        ]
      end

      def self.example_code
        [
          'appforshare(release_notes: "Fixes the login crash")',
          'appforshare(channel: "beta")',
          'appforshare(file: "app/build/outputs/apk/release/app-release.apk", fail_on: "blocked")'
        ]
      end

      def self.category
        :beta
      end

      def self.is_supported?(platform)
        %i[ios android].include?(platform)
      end
    end
  end
end
