# frozen_string_literal: true

module TeamsConnector
  class Configuration
    DEFAULT_TEMPLATE_DIR = %w[templates teams_connector].freeze

    attr_accessor :default, :channels, :always_use_default, :method, :template_dir, :color

    def initialize
      @default = nil
      @channels = {}
      @always_use_default = false
      @method = :direct
      @template_dir = DEFAULT_TEMPLATE_DIR
      @color = '3f95b5'
    end

    def default=(channel)
      raise ArgumentError, "Desired default channel '#{channel}' is not configured" unless @channels.key?(channel)
      @default = channel
    end

    def method=(method)
      raise ArgumentError, "Method '#{method.to_s}' is not supported" unless [:direct, :sidekiq, :testing].include? method
      raise ArgumentError, 'Sidekiq is not available' if method == :sidekiq && !defined? Sidekiq
      @method = method
    end

    def channel(name, url)
      @channels[name] = url;
    end

    def load_from_rails_credentials
      unless defined? Rails
        raise RuntimeError, 'This method is only available in Ruby on Rails.'
      end

      webhook_urls = Rails.application.credentials.teams_connector!
      webhook_urls.each do |entry|
        channel(entry[0], entry[1])
      end
    end
  end
end
