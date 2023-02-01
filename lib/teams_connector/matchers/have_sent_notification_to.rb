# frozen_string_literal: true

require_relative 'expected_number'
require_relative 'with'

module TeamsConnector
  module Matchers
    class HaveSentNotificationTo
      include RSpec::Matchers::Composable
      include TeamsConnector::Matchers::ExpectedNumber
      include TeamsConnector::Matchers::With

      class RelativityNotSupported < StandardError; end

      def initialize(channel, template)
        @filter = {
          channel: channel,
          template: template
        }
        @block = proc {}
        @data = nil
        @template_data = nil
        set_expected_number(:exactly, 1)
      end

      def failure_message
        msg = "expected to send #{base_message}"
        if @unmatching_ntfcts.any?
          msg += "\nSent notifications"
          msg += " to #{@filter[:channel]}" if @filter[:channel]
          msg += " of #{@filter[:template]}" if @filter[:template]
          msg += ':'
          @unmatching_ntfcts.each { |data| msg += "\n   #{data}" }
        end

        msg
      end

      def failure_message_when_negated
        "expected not to send #{base_message}"
      end

      def matches?(expectation)
        matching_notifications = in_block_notifications(expectation).select do |msg|
          @filter.map { |k, v| msg[k] == v unless v.nil? }.compact.all?
        end

        check(matching_notifications)
      end

      def supports_block_expectations?
        true
      end

      private

      def check(notifications)
        @matching_ntfcts, @unmatching_ntfcts = notifications.partition do |ntfct|
          check_partition(ntfct)
        end

        @matching_count = @matching_ntfcts.size

        check_result
      end

      def check_partition(ntfct)
        result = true

        result &= ntfct[:template] == @template_data unless @template_data.nil?

        decoded = JSON.parse(ntfct[:content])
        if @data.nil? || @data === decoded
          @block.call(decoded, ntfct)
          result & true
        else
          false
        end
      end

      def check_result
        case @expectation_type
        when :exactly then @expected_number == @matching_count
        when :at_most then @expected_number >= @matching_count
        when :at_least then @expected_number <= @matching_count
        else
          raise RelativityNotSupported
        end
      end

      def in_block_notifications(expectation)
        if expectation.is_a? Proc
          original_count = TeamsConnector.testing.requests.size
          expectation.call
          TeamsConnector.testing.requests.drop(original_count)
        else
          expectation
        end
      end

      def base_message
        msg = String("#{message_expectation_modifier} #{@expected_number} notifications")
        msg += " to #{@filter[:channel]}" if @filter[:channel]
        msg += " of #{@filter[:template]}" if @filter[:template]
        msg += " with template #{@template_data}" if @template_data
        msg += " with content #{data_description(@data)}" if @data
        msg + ", but sent #{@matching_count}"
      end

      def message_expectation_modifier
        case @expectation_type
        when :exactly then 'exactly'
        when :at_most then 'at most'
        when :at_least then 'at least'
        else
          raise RelativityNotSupported
        end
      end

      def data_description(data)
        if RSpec::Support.is_a_matcher?(data) && data.respond_to?(:description)
          data.description
        else
          data
        end
      end
    end
  end
end
