# frozen_string_literal: true

class RailsTest
  class Credentials
    def self.teams_connector!; end
  end

  class Application
    def self.credentials
      RailsTest::Credentials
    end
  end

  def self.application
    RailsTest::Application
  end
end

RSpec.describe TeamsConnector::Configuration do
  before do
    TeamsConnector.reset
  end

  subject { TeamsConnector.configuration }

  it 'has a default configuration' do
    is_expected.to have_attributes(default: nil)
    is_expected.to have_attributes(channels: {})
    is_expected.to have_attributes(always_use_default: false)
    is_expected.to have_attributes(method: :direct)
    is_expected.to have_attributes(template_dir: %w[templates teams_connector])
    is_expected.to have_attributes(color: '3f95b5')
  end

  it 'has a function to add a channel' do
    expect(subject.channels).to be_empty
    expect { subject.channel :default, 'https://test.url/' }.to(change { subject.channels })
    expect(subject.channels.count).to eq 1
    expect(subject.channels).to include :default
  end

  context 'default=' do
    it 'allows setting an existing channel as default' do
      subject.channel :new_default, 'https.//new.default.url/'
      expect { subject.default = :new_default }.to change { subject.default }.from(nil).to(:new_default)
    end

    it 'raises an error if a non existing channel is selected as default' do
      expect { subject.default = :not_existing_channel }.to raise_error ArgumentError
    end
  end

  context 'method=' do
    it 'supports direct' do
      subject.method = :direct
      expect(subject.method).to eq :direct
    end

    it 'supports sidekiq' do
      subject.method = :sidekiq
      expect(subject.method).to eq :sidekiq
    end

    it 'supports testing' do
      subject.method = :testing
      expect(subject.method).to eq :testing
    end

    it 'does not allow sidekiq when it is not available' do
      hide_const('Sidekiq')
      expect { subject.method = :sidekiq }.to raise_error ArgumentError
    end

    it 'does not allow invalid' do
      expect { subject.method = :invalid }.to raise_error ArgumentError
    end
  end

  context 'rails credentials' do
    it 'raises an error if Rails is not available' do
      expect { subject.load_from_rails_credentials }.to raise_error RuntimeError
    end

    context 'available' do
      it 'loads channels from credentials' do
        stub_const 'Rails', RailsTest
        allow(Rails.application.credentials)
          .to receive(:teams_connector!).and_return({
                                                      credentials_default: 'DEFAULT_TEST_URL',
                                                      credentials_other: 'OTHER_TEST_URL'
                                                    })
        subject.load_from_rails_credentials
        channels = [
          { credentials_default: 'DEFAULT_TEST_URL' },
          { credentials_other: 'OTHER_TEST_URL' }
        ]
        expect(subject.channels).to include(*channels)
      end
    end
  end
end
