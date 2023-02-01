
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teams_connector/version"

Gem::Specification.new do |spec|
  spec.name          = "teams_connector"
  spec.version       = TeamsConnector::VERSION
  spec.authors       = ["Lucas Keune"]
  spec.email         = ["lucas.keune@qurasoft.de"]

  spec.summary       = %q{Simple connector to send messages and cards to Microsoft Teams channels}
  spec.description   = %q{Send templated messages or adaptive cards to Microsoft Teams channels}
  spec.homepage      = "https://github.com/Qurasoft/teams_connector"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/Qurasoft/teams_connector"
    spec.metadata["changelog_uri"] = "https://github.com/Qurasoft/teams_connector/blob/main/CHANGES.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency 'sidekiq', '< 7'
  spec.add_development_dependency "simplecov"
end
