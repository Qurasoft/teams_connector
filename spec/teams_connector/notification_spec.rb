# frozen_string_literal: true

require 'sidekiq/testing'

RSpec.describe TeamsConnector::Notification do
  before :each do
    TeamsConnector.reset
    TeamsConnector.configure do |config|
      config.channel :other, 'http://localhost'
      config.channel :another, 'http://another'
      config.channel :default, 'http://default'
      config.default = :default
    end
    stub_request(:post, 'localhost')
    stub_request(:post, 'another')
    stub_request(:post, 'default')
  end

  subject { TeamsConnector::Notification.new(template: :test_card, channels: :other) }

  it 'initializes with template and channel' do
    expect(subject).to have_attributes(template: :test_card)
    expect(subject).to have_attributes(channels: [:other])
  end

  it 'delivers the message to the target' do
    subject.deliver_later

    expect(WebMock).to have_requested(:post, 'http://localhost').with headers: { "Content-Type": 'application/json' }
    expect(WebMock).not_to have_requested :post, 'http://default'
  end

  it 'delivers the message to the default target' do
    TeamsConnector.configuration.always_use_default = true
    subject.deliver_later

    expect(WebMock).to have_requested(:post, 'http://default').with headers: { "Content-Type": 'application/json' }
    expect(WebMock).not_to have_requested :post, 'http://localhost'
  end

  context 'multiple channels' do
    subject { TeamsConnector::Notification.new(template: :test_card, channels: %i[other another]) }
    it 'initializes with multiple channels' do
      expect(subject).to have_attributes(template: :test_card)
      expect(subject).to have_attributes(channels: %i[other another])
    end

    it 'delivers the message to all targets' do
      subject.deliver_later

      expect(WebMock).to have_requested(:post, 'http://localhost').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).to have_requested(:post, 'http://another').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).not_to have_requested :post, 'http://default'
    end

    it 'delivers the message only to the default target' do
      TeamsConnector.configuration.always_use_default = true
      subject.deliver_later

      expect(WebMock).to have_requested(:post, 'http://default').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).not_to have_requested :post, 'http://localhost'
      expect(WebMock).not_to have_requested(:post, 'http://another')
    end
  end

  context 'target not available' do
    it 'raises an error' do
      stub_request(:post, 'localhost').to_return(status: 400)

      expect { subject.deliver_later }.to raise_error Net::HTTPServerException

      expect(WebMock).to have_requested(:post, 'http://localhost').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).not_to have_requested :post, 'http://default'
    end
  end

  context 'template not available' do
    subject { TeamsConnector::Notification.new(template: :card_not_available, channels: :other) }

    it 'raises an error' do
      expect { subject.deliver_later }.to raise_error ArgumentError

      expect(WebMock).not_to have_requested :post, 'http://default'
      expect(WebMock).not_to have_requested :post, 'http://localhost'
    end
  end

  context 'channel not configured' do
    subject { TeamsConnector::Notification.new(template: :test_card, channels: :not_configured) }

    it 'raises an error' do
      expect { subject.deliver_later }.to raise_error ArgumentError

      expect(WebMock).not_to have_requested :post, 'http://default'
      expect(WebMock).not_to have_requested :post, 'http://localhost'
    end
  end

  context 'sidekiq' do
    before :each do
      TeamsConnector.configure do |config|
        config.method = :sidekiq
      end
      Sidekiq::Testing.inline!
    end

    it 'delivers notifications' do
      subject.deliver_later

      expect(WebMock).to have_requested(:post, 'http://localhost').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).not_to have_requested :post, 'http://default'
    end
  end

  context 'testing' do
    before :each do
      TeamsConnector.reset_testing
      TeamsConnector.configure do |config|
        config.method = :testing
      end
    end

    it 'does not deliver http requests' do
      subject.deliver_later

      expect(WebMock).not_to have_requested :post, 'http://localhost'
      expect(WebMock).not_to have_requested :post, 'http://default'
      expect(WebMock).not_to have_requested :post, 'http://another'
    end

    it 'adds the request to the request list' do
      expect(TeamsConnector.testing.requests.count).to eq 0

      subject.deliver_later

      expect(TeamsConnector.testing.requests.count).to eq 1
    end
  end

  context 'default template directory' do
    before :each do
      TeamsConnector.configure do |config|
        config.template_dir = %w[does not exist]
      end
    end

    it 'falls back on bundled cards' do
      subject.deliver_later

      expect(WebMock).to have_requested(:post, 'http://localhost').with headers: { "Content-Type": 'application/json' }
      expect(WebMock).not_to have_requested :post, 'http://default'
    end
  end

  it 'pretty prints the template' do
    pretty_printed_template = <<~HEREDOC
      {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": "3f95b5",
        "summary": "This is a test summary",
        "sections": [
          {
            "markdown": true,
            "activityTitle": "Quokka",
            "activitySubtitle": "About the short-tailed scrub wallaby",
            "facts": [
              {
                "name": "Fun fact",
                "value": "Are always smiling and the 'happiest' animals on earth."
              }
            ]
          }
        ]
      }
    HEREDOC
    expect { subject.pretty_print }.to output(pretty_printed_template).to_stdout
  end
end
