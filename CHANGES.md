# Teams Connector Changelog

## 0.1.6
- Enable Github actions for ruby 3
- Enable Rubocop linting
- Bump compatibility to sidekiq 7

## 0.1.5
- RSpec Matchers for testing, thanks to [rspec-rails](https://github.com/rspec/rspec-rails) for their ActionCable `have_broadcasted_to` matcher as reference
- README update for testing
- Sometimes use testing mode internally
- Fixed code smells

## 0.1.4
- Add rudimentary testing method

## 0.1.3
- Allow sending a notification to multiple channels at the same time

## 0.1.2
- Use `TeamsConnector::Configuration#load_from_rails_credentials` to load encrypted channel URLs in your Rails environment

## 0.1.1
- Adaptive Card Notification
  - Send a more complex Adaptive Card instead of the basic Message Card
- Builder
  - Introduce Builder for [Adaptive Cards](https://docs.microsoft.com/en-us/outlook/actionable-messages/adaptive-card) generation
  - Directly create messages with TeamsConnector::Notification::AdaptiveCard and the adaptive_card default template
  - Output as JSON for creation of custom templates
  - Supports
    - Text
    - Container
    - Facts
- Notification 
  - Change constructor from numbered to named parameters
  - Pretty print JSON to STDOUT with #pretty_print

## 0.1.0
- Initial commit of the Teams Connector gem
- Send messages as cards defined by JSON templates to configured Microsoft Teams channels
