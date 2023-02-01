# frozen_string_literal: true

module TeamsConnector
  module Matchers
    module With
      def with(data = nil, &block)
        @data = data
        @block = block if block
        self
      end

      def with_template(template = nil)
        @template_data = template
        self
      end
    end
  end
end
