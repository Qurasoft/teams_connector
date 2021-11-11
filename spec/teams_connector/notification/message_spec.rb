RSpec.describe TeamsConnector::Notification::Message do
  before :each do
    TeamsConnector.reset
    TeamsConnector.configure do |config|
      config.template_dir = %w[app views teams_connector]
      config.channel :other, "http://localhost"
      config.channel :default, "http://default"
      config.default = :default
    end
    stub_request(:post, "localhost")
    stub_request(:post, "default")
  end

  subject { TeamsConnector::Notification::Message.new(:test_card, "Summary") }

  it "initializes with template, summary, content, and the default channel" do
    expect(subject).to be_a TeamsConnector::Notification
    expect(subject).to have_attributes(template: :test_card)
    expect(subject).to have_attributes(channel: :default)
    expect(subject).to have_attributes(summary: "Summary")
    expect(subject).to have_attributes(content: {})
  end
end
