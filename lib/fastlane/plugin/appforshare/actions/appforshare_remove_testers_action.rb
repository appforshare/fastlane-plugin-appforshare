require_relative 'appforshare_base'

module Fastlane
  module Actions
    class AppforshareRemoveTestersAction < Action
      def self.run(params)
        s = Helper::AppforshareShared
        emails = s.list(params[:emails], params[:file])
        UI.user_error!('No tester emails. Pass emails: or file:') if emails.empty?
        r = s.client(params).remove_testers(emails, project: params[:project])
        UI.success("#{r['removed']} tester(s) removed#{params[:project] ? ' from the project' : ''}.")
        UI.important("Not testers: #{r['notFound'].join(', ')}") unless (r['notFound'] || []).empty?
        r
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Remove testers from AppForShare, or with project: only the access you gave them to that project (Team)'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'Hash with removed and notFound'
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option, *s.emails_options, s.project_option, s.api_option]
      end

      def self.example_code
        ['appforshare_remove_testers(emails: "omar@example.com")']
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
