# Minimal stand-in for the fastlane runtime so the plugin's actions run in tests without the fastlane gem
# (it needs native extensions this VM cannot build). Only what the actions use: Action, UI, ConfigItem, lane_context.
module Fastlane
  class Action; end

  module Actions
    module SharedValues
      IPA_OUTPUT_PATH = :IPA_OUTPUT_PATH
      GRADLE_APK_OUTPUT_PATH = :GRADLE_APK_OUTPUT_PATH
    end

    def self.lane_context
      @lane_context ||= {}
    end
  end

  class UserError < StandardError; end

  module UI
    def self.log
      @log ||= []
    end

    %i[message success important].each { |m| define_singleton_method(m) { |s| log << [m, s.to_s] } }

    def self.user_error!(s)
      raise UserError, s
    end
  end
end

module FastlaneCore
  class ConfigItem
    attr_reader :key, :default_value, :type

    def initialize(key:, default_value: nil, type: nil, **_rest)
      @key = key
      @default_value = default_value
      @type = type
    end
  end
end

Boolean = Object unless defined?(Boolean)
