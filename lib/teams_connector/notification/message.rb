module TeamsConnector
  class Notification::Message < Notification
    attr_accessor :summary, :content

    def initialize(template, summary, content = {}, channel = TeamsConnector.configuration.default)
      super(template, channel)
      @summary = summary
      @content = content
    end
  end
end
