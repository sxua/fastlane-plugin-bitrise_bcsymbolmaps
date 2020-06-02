module Fastlane
  module Actions
    class BitriseCleanBcsymbolmapsAction < Action
      def self.run(params)
        FileUtils.rm_rf Dir.glob(File.join(Dir.pwd, "BCSymbolMaps*"))
        FileUtils.rm_rf File.join(Dir.pwd, "fastlane", "BCSymbolmaps")
      end

      def self.description
        "Cleans up downloaded artifacts."
      end

      def self.authors
        ["Oleksandr Skrypnyk"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
