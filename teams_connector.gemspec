# frozen_string_literal: true

require_relative 'lib/teams_connector/version'

Gem::Specification.new do |spec|
  spec.name          = 'teams_connector'
  spec.version       = TeamsConnector::VERSION
  spec.required_ruby_version = '>= 2.6'
  spec.authors       = ['Lucas Keune']
  spec.email         = ['lucas.keune@qurasoft.de']

  spec.summary       = 'Simple connector to send messages and cards to Microsoft Teams channels'
  spec.description   = 'Send templated messages or adaptive cards to Microsoft Teams channels'
  spec.homepage      = 'https://github.com/Qurasoft/teams_connector'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Qurasoft/teams_connector'
  spec.metadata['changelog_uri'] = 'https://github.com/Qurasoft/teams_connector/blob/main/CHANGES.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sidekiq', '< 7'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
end
