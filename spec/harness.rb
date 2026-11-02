# Runs one plugin action against an AppForShare API: ruby harness.rb <ActionClass> '<json params>'
# Prints one JSON line: { ok, result | error, log, lane }.
$LOAD_PATH.unshift File.expand_path('stub', __dir__)
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'json'
require 'fastlane/action'
require 'fastlane/plugin/appforshare'

name, raw = ARGV
klass = Fastlane::Actions.const_get(name)
given = JSON.parse(raw || '{}').transform_keys(&:to_sym)
params = klass.available_options.each_with_object({}) { |o, h| h[o.key] = o.default_value }
params.merge!(given)
begin
  result = klass.run(params)
  puts JSON.generate(ok: true, result: result, log: Fastlane::UI.log, lane: Fastlane::Actions.lane_context.transform_keys(&:to_s))
rescue Fastlane::UserError => e
  puts JSON.generate(ok: false, error: e.message, log: Fastlane::UI.log)
end
