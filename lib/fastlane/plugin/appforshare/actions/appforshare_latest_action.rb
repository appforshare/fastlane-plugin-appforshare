require_relative 'appforshare_base'

module Fastlane
  module Actions
    module SharedValues
      APPFORSHARE_LATEST_VERSION = :APPFORSHARE_LATEST_VERSION
      APPFORSHARE_LATEST_BUILD_NUMBER = :APPFORSHARE_LATEST_BUILD_NUMBER
      APPFORSHARE_LATEST_URL = :APPFORSHARE_LATEST_URL
    end

    class AppforshareLatestAction < Action
      def self.run(params)
        b = Helper::AppforshareShared.client(params).latest(platform: params[:platform], app: params[:app], channel: params[:channel])
        Actions.lane_context[SharedValues::APPFORSHARE_LATEST_VERSION] = b['version']
        Actions.lane_context[SharedValues::APPFORSHARE_LATEST_BUILD_NUMBER] = b['versionCode']
        Actions.lane_context[SharedValues::APPFORSHARE_LATEST_URL] = b['url']
        UI.success("Newest build: #{b['name']} #{b['version']} (#{b['versionCode']}) #{b['url']}")
        b
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Read the newest AppForShare build (version, build number, install link), for example to bump the build number'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'Hash with the build: version, versionCode, url, slug and more'
      end

      def self.output
        [['APPFORSHARE_LATEST_VERSION', 'Version of the newest build'], ['APPFORSHARE_LATEST_BUILD_NUMBER', 'Its build number'], ['APPFORSHARE_LATEST_URL', 'Its install link']]
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option,
         FastlaneCore::ConfigItem.new(key: :platform, env_name: 'APPFORSHARE_PLATFORM', description: 'ios or android', optional: true,
                                      verify_block: proc { |v| UI.user_error!('platform takes "ios" or "android"') unless %w[ios android].include?(v) }),
         FastlaneCore::ConfigItem.new(key: :app, env_name: 'APPFORSHARE_APP', description: 'Bundle id or package name', optional: true),
         FastlaneCore::ConfigItem.new(key: :channel, env_name: 'APPFORSHARE_CHANNEL', description: 'Only builds in this channel', optional: true),
         s.api_option]
      end

      def self.example_code
        ['latest = appforshare_latest(app: "com.example.shop", platform: "android")
increment_version_code(version_code: latest["versionCode"].to_i + 1)']
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
