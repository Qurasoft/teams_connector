require 'teams_connector/configuration'
require 'teams_connector/version'
require 'teams_connector/notification'
require 'teams_connector/notification/message'
require 'teams_connector/notification/adaptive_card'
require 'teams_connector/builder'

module TeamsConnector
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.project_root
    if defined?(Rails)
      return Rails.root
    end

    if defined?(Bundler)
      return Bundler.root
    end

    Dir.pwd
  end

  def self.gem_root
    spec = Gem::Specification.find_by_name("teams_connector")
    spec.gem_dir rescue project_root
  end
end
