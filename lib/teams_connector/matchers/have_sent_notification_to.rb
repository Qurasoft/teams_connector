module TeamsConnector
  module Matchers
    class HaveSentNotificationTo
      include RSpec::Matchers::Composable

      def initialize(channel)
        @channel = channel
        @block = proc { }
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
        "expected to send #{base_message}".tap do |msg|
          if @unmatching_ntfcts.any?
            msg << "\nSent notifications to #{@channel}:"
            @unmatching_ntfcts.each do |data|
              msg << "\n   #{data}"
            end
          end
        end
      end

      def failure_message_when_negated
        "expected not to send #{base_message}"
      end

      def matches?(expectation)
        if Proc === expectation
          original_count = TeamsConnector.testing.requests.size
          expectation.call
          in_block_notifications = TeamsConnector.testing.requests.drop(original_count)
        else
          in_block_notifications = expectation
        end

        in_block_notifications = in_block_notifications.select {|msg| msg[:channel] === @channel} unless @channel.nil?

        check(in_block_notifications)
      end

      def supports_block_expectations?
        true
      end

      private

      def check(notifications)
        @matching_ntfcts, @unmatching_ntfcts = notifications.partition do |ntfct|
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

        @matching_count = @matching_ntfcts.size

        case @expectation_type
        when :exactly then @expected_number == @matching_count
        when :at_most then @expected_number >= @matching_count
        when :at_least then @expected_number <= @matching_count
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
        "#{message_expectation_modifier} #{@expected_number} notifications to #{@channel}".tap do |msg|
          msg << " with template #{@template_data}" unless @template_data.nil?
          msg << " with content #{data_description(@data)}" unless @data.nil?
          msg << ", but sent #{@matching_count}"
        end
      end

      def message_expectation_modifier
        case @expectation_type
        when :exactly then "exactly"
        when :at_most then "at most"
        when :at_least then "at least"
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
