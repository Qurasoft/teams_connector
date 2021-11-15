# Teams Connector

[![Gem Version](https://badge.fury.io/rb/teams_connector.svg)](https://badge.fury.io/rb/teams_connector)
![RSpec](https://github.com/qurasoft/teams_connector/actions/workflows/ruby.yml/badge.svg)

Welcome to Teams Connector. This gem allows you to easily send messages from your ruby project to Microsoft Teams channels.
It integrates in your rails project, when you are using bundler or even in plain ruby projects.

The messages can be send synchronous or asynchronous with [Sidekiq](https://github.com/mperham/sidekiq). 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'teams_connector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install teams_connector

## Usage
After setting up the Incoming Webhook Connector four your Microsoft Teams channel, it is as simple as configuring the channel and creating a new `TeamsConnector::Notification`.

```ruby
# Configuration
TeamsConnector.configure do |config|
  config.channel :channel_id, "https://<YOUR COMPLETE WEBHOOK URL GOES HERE>"
end

# Send a test card to your channel
TeamsConnector::Notification.new(:test_card, :channel_id).deliver_later

# Send a card with a list of facts
content = {
  title: "Teams Connector Readme",
  subtitle: "A list of facts",
  facts: {
    "Usage": "Testing the facts Card"
  }
}
TeamsConnector::Notification::Message.new(:facts_card, "This is a summary", content).deliver_later
```
This gem provides some basic templates in its default template path. You can also define your own templates in your own path. The default templates will be still available so you can mix and match.

### Default templates

Template name | Description
-----|-------
:adaptive_card | A card with the body of an adaptive card for more complex scenarios
:facts_card | A card with title, subtitle and a list of facts
:test_card | A simple text message without any configurable content for testing

### Custom Templates

Custom templates are stored in the directory specified by the configuration option `template_dir`. As an array of strings, describing the path relative to the project root. When using Rails or Bundler their root is used, otherwise it is the current working directory.

Templates are json files with the extension `.json.erb`. The file is parsed and populated by the ruby ERB module.

### Builder

You can use TeamsConnector::Builder to create Adaptive Cards directly in ruby. YOu can output the result of the builder as JSON for future use with `TeamsController::Notification::AdaptiveCard#pretty_print`.

```ruby
builder = TeamsConnector::Builder.container do |content|
  content << TeamsConnector::Builder.text("This is an introductory text for the following facts")
  content << TeamsConnector::Builder.facts { |facts|
    facts["Usage"] = "Testing the adaptive card builder"
    facts["Quokka fact"] = "They are funny little creatures"
  }
end

TeamsConnector::Notification::AdaptiveCard.new(content: builder).deliver_later
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can define the channels you use for testing in the file `bin/channels.yml` or directly in the `bin/console` script.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qurasoft/teams_connector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
