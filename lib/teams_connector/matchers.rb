# frozen_string_literal: true

require 'teams_connector/matchers/have_sent_notification_to'

module TeamsConnector
  module Matchers
    def have_sent_notification_to(channel = nil, template = nil)
      HaveSentNotificationTo.new(channel, template)
    end

    alias_method :send_notification_to, :have_sent_notification_to
  end
end
