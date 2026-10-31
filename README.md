# fastlane-plugin-appforshare

Upload iOS (.ipa) and Android (.apk) builds to [AppForShare](https://appforshare.io) from fastlane and get an
install link and QR code page for your testers.

```sh
fastlane add_plugin appforshare
```

```ruby
lane :beta do
  gym(export_method: "ad-hoc")
  appforshare(release_notes: "Fixes the login crash", fail_on: "blocked")
  slack(message: "New build: #{lane_context[SharedValues::APPFORSHARE_URL]}")
end
```

Set `APPFORSHARE_TOKEN` (Dashboard, Settings, API tokens; Pro and Team plans). Without `file:` the action takes
the build from gym (`IPA_OUTPUT_PATH`) or gradle (`GRADLE_APK_OUTPUT_PATH`).

| Option | Env | |
|---|---|---|
| `api_token` | `APPFORSHARE_TOKEN` | API token |
| `file` | `APPFORSHARE_FILE` | .ipa or .apk |
| `release_notes` | `APPFORSHARE_RELEASE_NOTES` | Shown to testers (Pro and Team) |
| `channel` | `APPFORSHARE_CHANNEL` | Put the build into a channel (`beta`, `live`), created on first use. Its link always opens the newest build in it (Pro and Team) |
| `fail_on` | `APPFORSHARE_FAIL_ON` | `blocked` or `review`: fail the lane on the store readiness check. The build stays uploaded. |

Lane context after the action: `APPFORSHARE_URL`, `APPFORSHARE_SLUG`, `APPFORSHARE_READINESS`, and with `channel:`
`APPFORSHARE_CHANNEL_URL`. The store readiness
check is guidance about current App Store and Google Play rules, not a promise of approval.

MIT license. Source: https://github.com/appforshare/fastlane-plugin-appforshare
