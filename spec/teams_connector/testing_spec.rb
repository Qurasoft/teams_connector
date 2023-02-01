# frozen_string_literal: true

RSpec.describe TeamsConnector::Configuration do
  before do
    TeamsConnector.reset_testing
  end

  subject { TeamsConnector.testing }

  it 'has a default state' do
    is_expected.to have_attributes(requests: [])
  end

  it 'has a function to perform a request' do
    expect(subject.requests).to be_empty
    expect { subject.perform_request :default, :fact_card, 'CONTENT' }.to change { subject.requests }
    expect(subject.requests.count).to eq 1
    expect(subject.requests).to include(hash_including(:time, content: 'CONTENT', channel: :default, template: :fact_card))
  end
end
