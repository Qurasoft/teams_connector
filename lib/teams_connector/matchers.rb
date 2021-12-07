require 'teams_connector/matchers/have_sent_notification_to'

module TeamsConnector
  module Matchers
    def have_sent_notification_to(channel = nil)
      HaveSentNotificationTo.new(channel)
    end

    alias_method :send_notification_to, :have_sent_notification_to
  end
end
