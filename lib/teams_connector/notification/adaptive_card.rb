module TeamsConnector
  class Notification::AdaptiveCard < Notification
    attr_accessor :content

    def initialize(template: :adaptive_card, content: {}, channel: TeamsConnector.configuration.default)
      super(template: template, channels: channel)
      if content.instance_of? TeamsConnector::Builder
        @content = {
          card: [content.result]
        }
      else
        @content = content
      end
    end
  end
end
