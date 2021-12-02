RSpec.describe TeamsConnector do
  it "has a version number" do
    expect(TeamsConnector::VERSION).not_to be nil
  end

  context "configuration" do
    subject { TeamsConnector.configuration }

    it "is a singleton" do
      is_expected.to be_a TeamsConnector::Configuration
      is_expected.to be TeamsConnector.configuration
    end

    it "can be reset" do
      old_configuration = TeamsConnector.configuration
      TeamsConnector.reset
      new_configuration = TeamsConnector.configuration

      expect(old_configuration).to be_a TeamsConnector::Configuration
      expect(new_configuration).to be_a TeamsConnector::Configuration
      expect(old_configuration).not_to be new_configuration
    end
  end

  context "#configure" do
    it "yields the configuration" do
      expect { |b| TeamsConnector.configure &b }.to yield_with_args TeamsConnector.configuration
    end
  end

  context "testing" do
    subject { TeamsConnector.testing }

    it "is a singleton" do
      is_expected.to be_a TeamsConnector::Testing
      is_expected.to be TeamsConnector.testing
    end

    it "can be reset" do
      old_testing = TeamsConnector.testing
      TeamsConnector.reset_testing
      new_testing = TeamsConnector.testing

      expect(old_testing).to be_a TeamsConnector::Testing
      expect(new_testing).to be_a TeamsConnector::Testing
      expect(old_testing).not_to be new_testing
    end
  end

  context "project_root" do
    it "is working directory" do
      hide_const('Rails')
      hide_const('Bundler')

      expect(TeamsConnector.project_root).to eq(Dir.pwd)
    end

    it "is bundler root if running in bundler" do
      test_bundler = Class.new do
        def self.root
          "BUNDLER_ROOT_PATH"
        end
      end
      stub_const('Bundler', test_bundler)
      hide_const('Rails')

      expect(TeamsConnector.project_root).to eq("BUNDLER_ROOT_PATH")
    end

    it "is rails root if running in rails" do
      test_rails = Class.new do
        def self.root
          "RAILS_ROOT_PATH"
        end
      end
      stub_const('Rails', test_rails)
      hide_const('Bundler')

      expect(TeamsConnector.project_root).to eq("RAILS_ROOT_PATH")
    end
  end
end
