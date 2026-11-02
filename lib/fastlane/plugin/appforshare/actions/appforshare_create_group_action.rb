require_relative 'appforshare_base'

module Fastlane
  module Actions
    class AppforshareCreateGroupAction < Action
      def self.run(params)
        s = Helper::AppforshareShared
        c = s.client(params)
        r = c.create_group(params[:name], project: params[:project])
        UI.success("Group #{r['name']} made.")
        emails = s.list(params[:emails], params[:file])
        unless emails.empty?
          m = c.add_group_members(params[:name], emails, notify: params[:notify])
          UI.success("#{m['group']} now has #{m['members']} member(s).")
        end
        r
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Make an AppForShare tester group, optionally on a project and with members (Team)'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'Hash with the group id and name'
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option,
         FastlaneCore::ConfigItem.new(key: :name, env_name: 'APPFORSHARE_GROUP', description: 'Group name', optional: false),
         s.project_option, *s.emails_options,
         FastlaneCore::ConfigItem.new(key: :notify, env_name: 'APPFORSHARE_NOTIFY', description: 'Invite members who can install something new', optional: true, type: Boolean, default_value: true),
         s.api_option]
      end

      def self.example_code
        ['appforshare_create_group(name: "Client QA", project: 12, emails: "qa@client.com")']
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
