require_relative 'appforshare_base'

module Fastlane
  module Actions
    class AppforshareAddTestersAction < Action
      def self.run(params)
        s = Helper::AppforshareShared
        emails = s.list(params[:emails], params[:file])
        UI.user_error!('No tester emails. Pass emails: or file:') if emails.empty?
        r = s.client(params).add_testers(emails, project: params[:project], groups: s.list(params[:groups]), notify: params[:notify])
        UI.success("#{r['added']} new tester(s) added, #{r['updated']} already there#{params[:notify] ? '' : ', no invites sent'}.")
        r
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Add testers to AppForShare, optionally to a project and tester groups (Team)'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'Hash with added and updated counts'
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option, *s.emails_options, s.project_option,
         FastlaneCore::ConfigItem.new(key: :groups, env_name: 'APPFORSHARE_GROUPS', description: 'Tester group names, comma separated or an array', optional: true, type: Array),
         FastlaneCore::ConfigItem.new(key: :notify, env_name: 'APPFORSHARE_NOTIFY', description: 'Email new testers an invite', optional: true, type: Boolean, default_value: true),
         s.api_option]
      end

      def self.example_code
        ['appforshare_add_testers(emails: "sara@example.com, omar@example.com", groups: "Client QA")', 'appforshare_add_testers(file: "testers.txt", project: 12, notify: false)']
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
