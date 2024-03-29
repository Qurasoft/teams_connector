# frozen_string_literal: true

module TeamsConnector
  class Notification
    class AdaptiveCard < Notification
      attr_accessor :content

      def initialize(template: :adaptive_card, content: {}, channel: TeamsConnector.configuration.default)
        super(template: template, channels: channel)
        @content =
          if content.instance_of? TeamsConnector::Builder
            {
              card: [content.result]
            }
          else
            content
          end
      end
    end
  end
end
