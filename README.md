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
| `groups` | `APPFORSHARE_GROUPS` | Share the build with these tester groups when it is ready (Team) |
| `testers` | `APPFORSHARE_TESTERS` | Share the build with these tester emails when it is ready (Team) |
| `fail_on` | `APPFORSHARE_FAIL_ON` | `blocked` or `review`: fail the lane on the store readiness check. The build stays uploaded. |

Lane context after the action: `APPFORSHARE_URL`, `APPFORSHARE_SLUG`, `APPFORSHARE_READINESS`, and with `channel:`
`APPFORSHARE_CHANNEL_URL`. The store readiness
check is guidance about current App Store and Google Play rules, not a promise of approval.

## Testers, groups and devices

The same jobs as Firebase App Distribution's fastlane actions, with no Google account for your testers.

| Action | What it does |
|---|---|
| `appforshare_add_testers(emails:, file:, project:, groups:, notify:)` | Add testers, optionally to a project and groups (Team) |
| `appforshare_remove_testers(emails:, file:, project:)` | Remove testers, or with `project:` only the access you gave them there (Team) |
| `appforshare_create_group(name:, project:, emails:)` | Make a tester group, optionally on a project and with members (Team) |
| `appforshare_delete_group(name:)` | Delete a group; its members stay testers (Team) |
| `appforshare_udids(output_file:)` | Write the UDIDs testers sent to a file in Apple's format (`APPFORSHARE_UDIDS_FILE`) |
| `appforshare_latest(app:, platform:, channel:)` | Newest build: `APPFORSHARE_LATEST_VERSION`, `APPFORSHARE_LATEST_BUILD_NUMBER`, `APPFORSHARE_LATEST_URL` |

```ruby
lane :devices do
  appforshare_udids(output_file: "devices.txt")
  register_devices(devices_file: "devices.txt")
  match(type: "adhoc", force_for_new_devices: true)
end

lane :beta_android do
  latest = appforshare_latest(app: "com.example.shop", platform: "android")
  increment_version_code(version_code: latest["versionCode"].to_i + 1)
  gradle(task: "assembleRelease")
  appforshare(groups: "Client QA", testers: "pm@client.com")
end
```

MIT license. Source: https://github.com/appforshare/fastlane-plugin-appforshare
