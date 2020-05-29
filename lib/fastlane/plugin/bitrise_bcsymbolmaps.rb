require 'fastlane/plugin/bitrise_bcsymbolmaps/version'

module Fastlane
  module BitriseBcsymbolmaps
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

Fastlane::BitriseBcsymbolmaps.all_classes.each do |current|
  require current
end
