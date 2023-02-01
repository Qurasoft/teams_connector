# frozen_string_literal: true

require 'teams_connector/configuration'
require 'teams_connector/version'
require 'teams_connector/notification'
require 'teams_connector/notification/message'
require 'teams_connector/notification/adaptive_card'
require 'teams_connector/builder'

module TeamsConnector
  class << self
    attr_accessor :configuration, :testing
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

  def self.testing
    require 'teams_connector/testing'
    @testing ||= Testing.new
  end

  def self.reset_testing
    require 'teams_connector/testing'
    @testing = Testing.new
  end

  def self.project_root
    return Rails.root if defined?(Rails)
    return Bundler.root if defined?(Bundler)

    Dir.pwd
  end

  def self.gem_root
    spec = Gem::Specification.find_by_name('teams_connector')
    begin
      spec.gem_dir
    rescue NoMethodError
      project_root
    end
  end
end
