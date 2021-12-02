require 'erb'
require 'json'
require 'net/http'
require 'teams_connector/post_worker' if defined? Sidekiq

module TeamsConnector
  class Notification
    attr_accessor :template, :channels

    def initialize(template: nil, channels: TeamsConnector.configuration.default)
      @template = template
      @channels = channels.instance_of?(Array) ? channels : [channels]
    end

    def deliver_later
      template_path = find_template

      renderer = ERB.new(File.read(template_path))
      renderer.location = [template_path.to_s, 0]

      content = renderer.result(binding)

      channels = TeamsConnector.configuration.always_use_default ? [TeamsConnector.configuration.default] : @channels
      channels.each do |channel|
        url = TeamsConnector.configuration.channels[channel]
        raise ArgumentError, "The Teams channel '#{channel}' is not available in the configuration." if url.nil?

        if TeamsConnector.configuration.method == :sidekiq
          TeamsConnector::PostWorker.perform_async(url, content)
        elsif TeamsConnector.configuration.method == :testing
          TeamsConnector.testing.perform_request channel, @template, content
        else
          response = Net::HTTP.post(URI(url), content, { "Content-Type": "application/json" })
          response.value
        end
      end
    end

    def pretty_print
      template_path = find_template

      renderer = ERB.new(File.read(template_path))
      renderer.location = [template_path.to_s, 0]
      content = renderer.result(binding)

      puts JSON.pretty_generate(JSON.parse(content))
    end

    private

    def find_template
      path = File.join(TeamsConnector::project_root, *TeamsConnector.configuration.template_dir, "#{@template.to_s}.json.erb")
      unless File.exist? path
        path = File.join(TeamsConnector::gem_root, *TeamsConnector::Configuration::DEFAULT_TEMPLATE_DIR, "#{@template.to_s}.json.erb")
      end
      raise ArgumentError, "The template '#{@template}' is not available." unless File.exist? path

      path
    end
  end
end
