require_relative 'appforshare_base'

module Fastlane
  module Actions
    module SharedValues
      APPFORSHARE_UDIDS_FILE = :APPFORSHARE_UDIDS_FILE
    end

    class AppforshareUdidsAction < Action
      def self.run(params)
        text = Helper::AppforshareShared.client(params).udids
        File.write(params[:output_file], text)
        count = [text.lines.count - 1, 0].max
        Actions.lane_context[SharedValues::APPFORSHARE_UDIDS_FILE] = params[:output_file]
        UI.success("#{count} device(s) written to #{params[:output_file]}")
        params[:output_file]
      rescue Helper::AppforshareClient::Error => e
        UI.user_error!(e.message)
      end

      def self.description
        'Write the UDIDs testers sent to AppForShare to a file in Apple\'s Register Multiple Devices format'
      end

      def self.details
        'Pass the file to register_devices(devices_file:) and then match(force_for_new_devices: true), like Firebase\'s get_udids. ' \
          'AppForShare can also register devices on Apple and remake the profile for you from the Devices page.'
      end

      def self.authors
        ['AppForShare']
      end

      def self.return_value
        'Path of the written file'
      end

      def self.output
        [['APPFORSHARE_UDIDS_FILE', 'Path of the devices file']]
      end

      def self.available_options
        s = Helper::AppforshareShared
        [s.token_option,
         FastlaneCore::ConfigItem.new(key: :output_file, env_name: 'APPFORSHARE_UDIDS_FILE', description: 'Where to write the devices file', optional: true, default_value: 'appforshare-devices.txt'),
         s.api_option]
      end

      def self.example_code
        ['appforshare_udids(output_file: "devices.txt")
register_devices(devices_file: "devices.txt")
match(type: "adhoc", force_for_new_devices: true)']
      end

      def self.category
        :beta
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
