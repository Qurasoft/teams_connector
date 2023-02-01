# frozen_string_literal: true

module TeamsConnector
  class Builder
    attr_accessor :type, :content

    def initialize
      yield self
    end

    def self.text(text)
      TeamsConnector::Builder.new { |entry| entry.text text }
    end

    def text(text)
      @type = :text
      @content = text
    end

    def self.container(&block)
      TeamsConnector::Builder.new { |entry| entry.container(&block) }
    end

    def container
      @type = :container
      @content = []
      yield @content
    end

    def self.facts(&block)
      TeamsConnector::Builder.new { |entry| entry.facts(&block) }
    end

    def facts
      @type = :facts
      @content = {}
      yield @content
    end

    def result
      case @type
      when :container
        result_container
      when :facts
        result_facts
      when :text
        result_text
      else
        raise TypeError, "The type #{@type} is not supported by the TeamsConnector::Builder"
      end
    end

    private

    def result_container
      {
        type: 'Container',
        items: @content.map(&:result)
      }
    end

    def result_facts
      {
        type: 'FactSet',
        facts: @content.map { |fact| { title: fact[0], value: fact[1] } }
      }
    end

    def result_text
      {
        type: 'TextBlock',
        text: @content
      }
    end
  end
end
