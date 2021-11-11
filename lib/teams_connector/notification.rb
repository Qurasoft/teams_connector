require 'erb'
require 'net/http'
require 'teams_connector/post_worker' if defined? Sidekiq

module TeamsConnector
  class Notification
    attr_accessor :template, :channel

    def initialize(template, channel)
      @template = template
      @channel = channel
    end

    def deliver_later
      template_path = find_template

      renderer = ERB.new(File.read(template_path))
      renderer.location = [template_path.to_s, 0]

      url = TeamsConnector.configuration.channels[@channel]
      url = TeamsConnector.configuration.channels[TeamsConnector.configuration.default] if TeamsConnector.configuration.always_use_default
      raise ArgumentError, "The Teams channel '#{@channel}' is not available in the configuration." if url.nil?

      content = renderer.result(binding)

      if TeamsConnector.configuration.method == :sidekiq
        TeamsConnector::PostWorker.perform_async(url, content)
      else
        response = Net::HTTP.post(URI(url), content, { "Content-Type": "application/json" })
        response.value
      end
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
