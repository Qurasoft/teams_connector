# frozen_string_literal: true

RSpec.describe TeamsConnector::Notification::Message do
  before :each do
    TeamsConnector.reset
    TeamsConnector.configure do |config|
      config.template_dir = %w[app views teams_connector]
      config.channel :other, 'http://localhost'
      config.channel :default, 'http://default'
      config.default = :default
      config.method = :testing
    end
  end

  subject { TeamsConnector::Notification::Message.new(:test_card, 'Summary') }

  it 'initializes with template, summary, content, and the default channel' do
    expect(subject).to be_a TeamsConnector::Notification
    expect(subject).to have_attributes(template: :test_card)
    expect(subject).to have_attributes(channels: [:default])
    expect(subject).to have_attributes(summary: 'Summary')
    expect(subject).to have_attributes(content: {})
  end

  it 'sends a notification with the content' do
    expect { subject.deliver_later }.to have_sent_notification_to(:default).with_template(:test_card).with { |content|
      expect(content['summary']).to eq 'This is a test summary'
      expect(content['sections']).to include(hash_including('facts', 'markdown' => true, 'activityTitle' => 'Quokka', 'activitySubtitle' => 'About the short-tailed scrub wallaby'))
    }
  end
end
