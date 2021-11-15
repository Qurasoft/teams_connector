RSpec.describe TeamsConnector::Builder do
  subject { TeamsConnector::Builder.new {} }

  it "is a builder" do
    is_expected.to be_a TeamsConnector::Builder
  end

  describe "test helper" do
    subject { TeamsConnector::Builder.text "Test Text" }

    it "creates a text element" do
      is_expected.to have_attributes type: :text, content: "Test Text"
    end
  end

  describe "container helper" do
    subject { TeamsConnector::Builder.container { |items|
      items << TeamsConnector::Builder.text("Container Test Text")
      items << TeamsConnector::Builder.text("Container Test Text #2")
    } }

    it "creates a container with the specified items" do
      is_expected.to have_attributes type: :container,
                                     content: match_array([
                                                            have_attributes(type: :text, content: "Container Test Text"),
                                                            have_attributes(type: :text, content: "Container Test Text #2")
                                                          ])
    end
  end

  describe "facts helper" do
    subject { TeamsConnector::Builder.facts { |facts| facts["First fact"] = "This is a test" } }

    it "creates a fact set with the specified entries" do
      is_expected.to have_attributes type: :facts, content: { "First fact" => "This is a test" }
    end
  end

  describe "result" do
    subject {
      TeamsConnector::Builder.container { |items|
        items << TeamsConnector::Builder.text("Test Text")
        items << TeamsConnector::Builder.facts { |facts|
          facts["First Fact"] = "First Fact Text"
        }
      }.result
    }

    it "gives the result as a hash translated to Adaptive Card syntax" do
      is_expected.to match type: "Container",
                           items: [
                             { type: "TextBlock", text: "Test Text" },
                             { type: "FactSet", facts: [
                               { title: "First Fact", value: "First Fact Text" }
                             ] }
                           ]
    end

    describe "failure" do
      subject { TeamsConnector::Builder.new { |builder| builder.type = :invalid } }
      it "raises an error with an unsupported type" do
        expect { subject.result }.to raise_error TypeError
      end
    end
  end
end