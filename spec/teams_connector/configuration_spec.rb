RSpec.describe TeamsConnector::Configuration do
  before do
    TeamsConnector.reset
  end

  subject { TeamsConnector.configuration }

  it "has a default configuration" do
    is_expected.to have_attributes(default: nil)
    is_expected.to have_attributes(channels: {})
    is_expected.to have_attributes(always_use_default: false)
    is_expected.to have_attributes(method: :direct)
    is_expected.to have_attributes(template_dir: %w[templates teams_connector])
    is_expected.to have_attributes(color: "3f95b5")
  end

  it "has a function to add a channel" do
    expect(subject.channels).to be_empty
    expect { subject.channel :default, "https://test.url/" }.to change { subject.channels }
    expect(subject.channels.count).to eq 1
    expect(subject.channels).to include :default
  end

  context "default=" do
    it "allows setting an existing channel as default" do
      subject.channel :new_default, "https.//new.default.url/"
      expect { subject.default = :new_default }.to change { subject.default }.from(nil).to(:new_default)
    end

    it "raises an error if a non existing channel is selected as default" do
      expect { subject.default = :not_existing_channel }.to raise_error ArgumentError
    end
  end

  context "method=" do
    it "supports direct" do
      subject.method = :direct
      expect(subject.method).to eq :direct
    end

    it "supports sidekiq" do
      subject.method = :sidekiq
      expect(subject.method).to eq :sidekiq
    end

    it "does not allow sidekiq when it is not available" do
      hide_const("Sidekiq")
      expect { subject.method = :sidekiq }.to raise_error ArgumentError
    end

    it "does not allow invalid" do
      expect { subject.method = :invalid }.to raise_error ArgumentError
    end
  end
end
