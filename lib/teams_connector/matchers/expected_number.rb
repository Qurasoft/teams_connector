# frozen_string_literal: true

module TeamsConnector
  module Matchers
    module ExpectedNumber
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

      private

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
    end
  end
end
