# frozen_string_literal: true

module TeamsConnector
  module Matchers
    class HaveSentNotificationTo
      include RSpec::Matchers::Composable

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

      def with(data = nil, &block)
        @data = data
        @block = block if block
        self
      end

      def with_template(template = nil)
        @template_data = template
        self
      end

      def exactly(count)
        set_expected_number(:exactly, count)
        self
      end

      def at_least(count)
        set_expected_number(:at_least, count)
        self
      end

      def at_most(count)
        set_expected_number(:at_most, count)
        self
      end

      def times
        self
      end

      def once
        exactly(:once)
      end

      def twice
        exactly(:twice)
      end

      def thrice
        exactly(:thrice)
      end

      def failure_message
        msg = "expected to send #{base_message}"
        if @unmatching_ntfcts.any?
          msg += "\nSent notifications"
          msg += " to #{@filter[:channel]}" if @filter[:channel]
          msg += " of #{@filter[:template]}" if @filter[:template]
          msg += ':'
          @unmatching_ntfcts.each do |data|
            msg += "\n   #{data}"
          end
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
          result &= true
        else
          result = false
        end

        result
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

      def set_expected_number(relativity, count)
        @expectation_type = relativity
        @expected_number =
          case count
          when :once then 1
          when :twice then 2
          when :thrice then 3
          else Integer(count)
          end
      end

      def base_message
        msg = String("#{message_expectation_modifier} #{@expected_number} notifications")
        msg += " to #{@filter[:channel]}" if @filter[:channel]
        msg += " of #{@filter[:template]}" if @filter[:template]
        msg += " with template #{@template_data}" if @template_data
        msg += " with content #{data_description(@data)}" if @data
        msg += ", but sent #{@matching_count}"

        msg
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
