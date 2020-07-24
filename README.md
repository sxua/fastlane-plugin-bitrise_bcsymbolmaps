# bitrise_bcsymbolmaps plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-bitrise_bcsymbolmaps)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-bitrise_bcsymbolmaps`, add it to your project by running:

```bash
fastlane add_plugin bitrise_bcsymbolmaps
```

## About bitrise_bcsymbolmaps

Download BCSymbolMaps from Bitrise before uploading them to a crash reporting tool.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins`.

In order to download bitcode symbol maps, provide a Personal Access Token from Bitrise as well as a app slug (last segment of the app URL).
We're assuming that release builds are coming from `release/*` branches (thanks to [Gitflow](https://nvie.com/posts/a-successful-git-branching-model/)) and we only need successful builds (`status: "1"`).

```ruby
build = bitrise_download_bcsymbolmaps(
  api_access_token: ENV["BITRISE_TOKEN"],
  app_slug: ENV["BITRISE_APP_SLUG"],
  branch: "release/#{version}",
  status: "1"
)
```

This will return an object with two attributes: `build_number` and `commit_hash`. Having this information is sufficient to [download dSYMs from AppStore Connect](fastlane/Fastfile#L23-L27) and [create a release on Bugsnag](fastlane/Fastfile#L29-L34).

After all the operations are done, you might want to cleanup a work directory.

```ruby
bitrise_clean_bcsymbolmaps
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
