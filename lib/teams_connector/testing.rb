# frozen_string_literal: true

module TeamsConnector
  class Testing
    attr_reader :requests

    def initialize
      @requests = []
    end

    def perform_request(channel, template, content)
      @requests.push({ channel: channel, content: content, template: template, time: Time.now })
    end
  end
end
