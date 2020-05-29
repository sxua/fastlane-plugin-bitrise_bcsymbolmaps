require 'fastlane/action'
require 'date'
require 'json'
require 'net/http'
require 'uri'
require 'zip'

module Fastlane
  module Actions
    class BitriseDownloadBcsymbolmapsAction < Action
      API_VERSION = "v0.1"

      Build = Struct.new(:build_number, :commit_hash)

      def self.run(params)
        build_response = bitrise_get_latest_build(params[:api_access_token], params[:app_slug], params[:branch], params[:status])
        return if build_response.code != "200"
        build_slug = get_build_slug(build_response)
        build_number = get_build_number(build_response).to_s
        build_commit_hash = get_build_commit_hash(build_response)

        artifacts_response = bitrise_get_artifacts(params[:api_access_token], params[:app_slug], build_slug)
        return if artifacts_response.code != "200"
        artifact_slug = get_artifact_slug(artifacts_response)

        artifact_response = bitrise_get_artifact(params[:api_access_token], params[:app_slug], build_slug, artifact_slug)
        return if artifact_response.code != "200"
        artifact_link = get_artifact_link(artifact_response)

        destination_path = File.join(Dir.pwd, "fastlane", "BCSymbolMaps")
        prepare_destination_path(destination_path)
        zip_path = download_file_with_prompt(artifact_link, build_number)
        extract_zip(zip_path)

        Build.new(build_number, build_commit_hash)
      end

      def self.description
        "Download BCSymbolMaps from Bitrise before uploading them to a crash reporting tool."
      end

      def self.authors
        ["Oleksandr Skrypnyk"]
      end

      def self.return_value
        "Struct (build number, commit hash)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_access_token,
                                  env_name: "BITRISE_BCSYMBOLMAPS_API_TOKEN",
                               description: "Bitrise Personal Access Token",
                                  optional: false,
                              verify_block: proc do |value|
                                UI.user_error!("No token for bitrise_download_bcsymbolmaps action given, pass using `api_access_token: \"<YOUR TOKEN>\"`") unless value
                              end),
          FastlaneCore::ConfigItem.new(key: :app_slug,
                                  env_name: "BITRISE_BCSYMBOLMAPS_APP_SLUG",
                               description: "Bitrise App Slug",
                                  optional: false,
                              verify_block: proc do |value|
                                UI.user_error!("No app slug for bitrise_download_bcsymbolmaps action given, pass using `app_slug: \"<APP SLUG>\"`") unless value
                              end),
          FastlaneCore::ConfigItem.new(key: :branch,
                                  env_name: "BITRISE_BCSYMBOLMAPS_BRANCH",
                               description: "Git Branch",
                                  optional: false,
                              verify_block: proc do |value|
                                UI.user_error!("No git branch for bitrise_download_bcsymbolmaps action given, pass using `branch: \"<BRANCH>\"`") unless value
                              end),
          FastlaneCore::ConfigItem.new(key: :status,
                                  env_name: "BITRISE_BCSYMBOLMAPS_STATUS",
                               description: "Build Status",
                                  optional: true,
                              verify_block: proc do |value|
                                UI.user_error!("No status for bitrise_download_bcsymbolmaps action given, pass using `status: \"<STATUS>\"`") unless value
                              end)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.perform_api_request(token, path)
        uri = URI.parse("https://api.bitrise.io/#{API_VERSION}#{path}")
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = "application/json"
        request["Authorization"] = token
        req_options = {use_ssl: uri.scheme == "https"}
        Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end
      end

      def self.bitrise_get_latest_build(token, app_slug, branch, status)
        perform_api_request(token, "/apps/#{app_slug}/builds?branch=#{branch}&status=#{status}")
      end

      def self.get_latest_build(response)
        json = JSON.parse(response.body)
        json["data"].sort { |lhs, rhs| DateTime.parse(lhs["finished_at"]) <=> DateTime.parse(rhs["finished_at"]) }.first
      end

      def self.get_build_slug(response)
        get_latest_build(response)["slug"]
      end

      def self.get_build_number(response)
        get_latest_build(response)["build_number"]
      end
      
      def self.get_build_commit_hash(response)
        get_latest_build(response)["commit_hash"]
      end

      def self.bitrise_get_artifacts(token, app_slug, build_slug)
        perform_api_request(token, "/apps/#{app_slug}/builds/#{build_slug}/artifacts")
      end
      
      def self.get_artifact_slug(response)
        json = JSON.parse(response.body)
        json["data"].select { |artifact| artifact["artifact_type"] == "ios-ipa" }.first["slug"]
      end

      def self.bitrise_get_artifact(token, app_slug, build_slug, artifact_slug)
        perform_api_request(token, "/apps/#{app_slug}/builds/#{build_slug}/artifacts/#{artifact_slug}")
      end

      def self.get_artifact_link(response)
        json = JSON.parse(response.body)
        json["data"]["expiring_download_url"]
      end

      def self.extract_zip(file)
        Zip::File.open(file) do |zip_file|
          zip_file.glob("BCSymbolMaps/*.bcsymbolmap").each do |f|
            fpath = File.join(Dir.pwd, "fastlane", f.name)
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end

      def self.download_file_with_prompt(url, build_number)
        file_path = File.join(Dir.pwd, "BCSymbolMaps-#{build_number}.zip")

        if File.exists?(file_path)
          if UI.confirm("File at #{file_path} is already exists. Do you want to overwrite it?")
            UI.verbose("Overwriting an already exisiting file at #{file_path}")
            File.rm(file_path)
            self.download_file(url, file_path)
          else
            UI.verbose("Skipping download")
          end
        else
          UI.message("Downloading a BCSymbolMaps")
          self.download_file(url, file_path)
        end

        file_path
      end

      def self.download_file(url, file_path)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        res = http.get(uri.request_uri)
        File.binwrite(file_path, res.body)
      end

      def self.prepare_destination_path(destination_path)
        FileUtils.rm_r(destination_path) if Dir.exists?(destination_path)
        FileUtils.mkdir_p(destination_path)
      end
    end
  end
end
