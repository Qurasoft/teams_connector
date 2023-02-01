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

    def self.container
      TeamsConnector::Builder.new { |entry| entry.container { |items| yield items } }
    end

    def container
      @type = :container
      @content = []
      yield @content
    end

    def self.facts
      TeamsConnector::Builder.new { |entry| entry.facts { |facts| yield facts } }
    end

    def facts
      @type = :facts
      @content = {}
      yield @content
    end

    def result
      case @type
      when :container
        {
          type: 'Container',
          items: @content.map { |element| element.result }
        }
      when :facts
        {
          type: 'FactSet',
          facts: @content.map { |fact| { title: fact[0], value: fact[1] } }
        }
      when :text
        {
          type: 'TextBlock',
          text: @content
        }
      else
        raise TypeError, "The type #{@type} is not supported by the TeamsConnector::Builder"
      end
    end
  end
end
