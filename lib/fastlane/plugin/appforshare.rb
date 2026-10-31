require 'fastlane/plugin/appforshare/version'

module Fastlane
  module Appforshare
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

Fastlane::Appforshare.all_classes.each { |current| require current }
