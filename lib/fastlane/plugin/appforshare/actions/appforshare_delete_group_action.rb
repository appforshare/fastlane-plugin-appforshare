require_relative 'appforshare_base'

module Fastlane
  module Actions
    class AppforshareDeleteGroupAction < Action
      def self.run(params)
        r = Helper::AppforshareShared.client(params).delete_group(params[:name])
        UI.success("Group #{r['deleted']} deleted. Its members stay testers.")
        r
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Delete an AppForShare tester group; members keep access given to them directly (Team)'
      end

      def self.authors
        ['AppForShare']
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option, FastlaneCore::ConfigItem.new(key: :name, env_name: 'APPFORSHARE_GROUP', description: 'Group name', optional: false), s.api_option]
      end

      def self.example_code
        ['appforshare_delete_group(name: "Old beta")']
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
