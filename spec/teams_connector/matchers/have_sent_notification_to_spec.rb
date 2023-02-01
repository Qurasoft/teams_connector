# frozen_string_literal: true

RSpec.describe TeamsConnector::Matchers::HaveSentNotificationTo do
  before :all do
    TeamsConnector.reset
    TeamsConnector.configure do |config|
      config.channel :other, 'http://localhost'
      config.channel :another, 'http://another'
      config.channel :default, 'http://default'
      config.method = :testing
    end
  end

  def notification(template, channels)
    TeamsConnector::Notification.new(template: template, channels: channels).deliver_later
  end

  describe 'have_sent_notification_to' do
    it 'passes with default notification count (exactly one)' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default)
    end

    it 'passes without channel and default notification count' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to
    end

    it 'passes for alias' do
      expect {
        notification(:test_card, :default)
      }.to send_notification_to(:default)
    end

    it 'counts only notifications sent in block' do
      notification(:test_card, :default)
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default)
    end

    it 'passes when negated' do
      expect {}.not_to have_sent_notification_to(:default)
    end

    it 'passes with multiple channels' do
      expect {
        notification(:test_card, :default)
        notification(:test_card, :other)
      }.to have_sent_notification_to(:default)

      expect {
        notification(:test_card, [:default, :other])
      }.to have_sent_notification_to(:default)
    end

    it 'passes when chained' do
      expect {
        notification(:test_card, :default)
        notification(:test_card, :other)
      }.to have_sent_notification_to(:default).and have_sent_notification_to(:other)
    end

    it 'passes with :once count' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).exactly(:once)
    end

    it 'passes with :twice count' do
      expect {
        notification(:test_card, :default)
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).exactly(:twice)
    end

    it 'passes with :thrice count' do
      expect {
        notification(:test_card, :default)
        notification(:test_card, :default)
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).exactly(:thrice)
    end

    it 'passes with at_least count when sent notifications are over limit' do
      expect {
        notification(:test_card, :default)
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).at_least(:once)
    end

    it 'passes with at_most count when sent notifications are under limit' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).at_most(:once)
    end

    it 'fails when notification is not sent' do
      expect {
        expect {}.to have_sent_notification_to(:default)
      }.to raise_error(/expected to send exactly 1 notifications to default, but sent 0/)
    end

    it 'fails when too many notifications are sent' do
      expect {
        expect {
          notification(:test_card, :default)
          notification(:test_card, :default)
        }.to have_sent_notification_to(:default)
      }.to raise_error(/expected to send exactly 1 notifications to default, but sent 2/)
    end

    it 'reports correct number in fail error message' do
      notification(:test_card, :default)
      expect {
        expect {
        }.to have_sent_notification_to(:default).exactly(1)
      }.to raise_error(/expected to send exactly 1 notifications to default, but sent 0/)
    end

    it 'fails when negated but notification was sent' do
      expect {
        expect {
          notification(:test_card, :default)
        }.not_to have_sent_notification_to(:default)
      }.to raise_error(/expected not to send exactly 1 notifications to default, but sent 1/)
    end

    it 'passes with provided template' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).with_template(:test_card)
    end

    it 'generates failure message when template does not match' do
      expect {
        expect {
          notification(:test_card, :default)
        }.to have_sent_notification_to(:default).with_template(:wrong_card)
      }.to raise_error(/expected to send exactly 1 notifications to default with template wrong_card, but sent 0/)
    end

    it 'passes with provided content matchers' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).with(hash_including('@context', 'themeColor', 'summary', '@type' => 'MessageCard', 'sections' => include(hash_including('activityTitle', 'activitySubtitle', 'facts', 'markdown' => true))))
    end

    it 'generates failure message when content does not match' do
      expect {
        expect {
          notification(:test_card, :default)
        }.to have_sent_notification_to(:default).with(hash_including('content' => 'wrong'))
      }.to raise_error(/expected to send exactly 1 notifications to default with content hash_including/)
    end

    it 'passes with provided block' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).with { |content|
        expect(content['sections']).to include(hash_including('activityTitle', 'activitySubtitle', 'facts', 'markdown' => true))
      }
    end

    it 'passes with provided block' do
      expect {
        notification(:test_card, :default)
      }.to have_sent_notification_to(:default).with { |content, notification|
        expect(notification[:channel]).to eq :default
        expect(notification[:template]).to eq :test_card
        expect(content['sections']).to include(hash_including('activityTitle', 'activitySubtitle', 'facts', 'markdown' => true))
      }
    end

    describe 'with template filter' do
      before :all do
        TeamsConnector.configure do |config|
          config.template_dir = %w[spec templates]
        end
      end

      it 'passes with default notification count (exactly one)' do
        expect {
          notification(:test_card, :default)
        }.to have_sent_notification_to(nil, :test_card)
      end

      it 'passes for alias' do
        expect {
          notification(:test_card, :default)
        }.to send_notification_to(nil, :test_card)
      end

      it 'passes when negated' do
        expect {}.not_to have_sent_notification_to(nil, :test_card)
      end


      it 'counts only notifications sent with the template' do
        expect {
          notification(:spec_card, :default)
          notification(:test_card, :default)
        }.to have_sent_notification_to(nil, :test_card)
      end

      it 'counts only notifications sent to the channel' do
        expect {
          notification(:test_card, :default)
          notification(:test_card, :other)
        }.to have_sent_notification_to(:default, :test_card)
      end

      it 'passes when chained' do
        expect {
          notification(:test_card, :default)
          notification(:spec_card, :other)
        }.to have_sent_notification_to(:default, :test_card).and have_sent_notification_to(:other, :spec_card)
      end

      it 'passes when combined with a template expectation' do
        expect {
          notification(:test_card, :default)
          notification(:spec_card, :other)
        }.to have_sent_notification_to(:default, :test_card).with_template(:test_card)
      end

      it 'fails when too many notifications are sent' do
        expect {
          expect {
            notification(:test_card, :default)
            notification(:test_card, :default)
          }.to have_sent_notification_to(nil, :test_card)
        }.to raise_error(/expected to send exactly 1 notifications of test_card, but sent 2/)
      end

      it 'fails when too many notifications are sent' do
        expect {
          expect {
            notification(:test_card, :default)
            notification(:test_card, :default)
          }.to have_sent_notification_to(:default, :test_card)
        }.to raise_error(/expected to send exactly 1 notifications to default of test_card, but sent 2/)
      end
    end
  end
end
