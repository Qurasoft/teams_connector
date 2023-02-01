# frozen_string_literal: true

module TeamsConnector
  class Notification
    class Message < Notification
      attr_accessor :summary, :content

      def initialize(template, summary, content = {}, channel = TeamsConnector.configuration.default)
        super(template: template, channels: channel)
        @summary = summary
        @content = content
      end
    end
  end
end
