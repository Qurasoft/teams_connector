# frozen_string_literal: true

RSpec.describe 'template facts_card' do
  before :all do
    TeamsConnector.reset
    TeamsConnector.configure do |config|
      config.template_dir = %w[app views teams_connector]
      config.channel :default, 'http://default'
      config.default = :default
      config.method = :testing
    end
  end

  def notification
    content = {
      title: 'Teams Connector Readme',
      subtitle: 'A list of facts',
      facts: facts
    }
    TeamsConnector::Notification::Message.new(:facts_card, summary, content).deliver_later
  end

  let(:summary) { 'summary' }

  context 'with content' do
    let(:facts) { { 'test fact' => 'test content' } }

    it 'passes' do
      expect do
        notification
      end.to sent_notification_to?(:default).with(
        hash_including(
          '@context',
          'themeColor',
          'summary' => summary,
          '@type' => 'MessageCard',
          'sections' => include(
            hash_including(
              'activityTitle',
              'activitySubtitle',
              'facts' => [{ 'name' => 'test fact', 'value' => 'test content' }],
              'markdown' => true
            )
          )
        )
      )
    end
  end
end
