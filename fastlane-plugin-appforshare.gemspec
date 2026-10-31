lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/appforshare/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-appforshare'
  spec.version       = Fastlane::Appforshare::VERSION
  spec.author        = 'AppForShare'
  spec.email         = 'support@appforshare.io'
  spec.summary       = 'Upload iOS and Android builds to AppForShare and get an install link for testers.'
  spec.description   = 'Fastlane action that uploads an .ipa or .apk to AppForShare (appforshare.io), waits for it to be ready, ' \
                       'returns the install link and the store readiness status, and can fail the lane on readiness blockers.'
  spec.homepage      = 'https://appforshare.io/docs/ci'
  spec.license       = 'MIT'
  spec.metadata      = { 'homepage_uri' => spec.homepage, 'source_code_uri' => 'https://github.com/appforshare/fastlane-plugin-appforshare' }
  spec.files         = Dir['lib/**/*'] + %w[README.md LICENSE]
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6'
end
