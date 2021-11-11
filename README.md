# Teams Connector

[![Gem Version](https://badge.fury.io/rb/teams_connector.svg)](https://badge.fury.io/rb/teams_connector)

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
:test_card | A simple text message without any configurable content for testing
:facts_card | A card with title, subtitle and a list of facts

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/qurasoft/teams_connector. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
