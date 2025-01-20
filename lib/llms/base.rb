# frozen_string_literal: true

module Llms
  # Base API client
  class Base
    class ResultError < StandardError; end

    attr_reader :prompt, :result_format

    RESULT_FORMATS = %i[numbered_list json].freeze

    def initialize(prompt, model: nil, result_format: :json)
      @prompt = prompt
      @model = model

      raise ArgumentError, "Invalid result format: #{result_format}" unless RESULT_FORMATS.include?(result_format)

      @result_format = result_format
    end

    def self.clean_value(text)
      # rubocop:disable Style/SafeNavigationChainLength
      text&.strip
          &.gsub(/^Aucune?s?$/i, "")
          &.gsub(/\(?(?:Non (?:mentionnée?s?|disponibles?)|Aucune?s? .+ n'est mentionnée?s?\.?|Inconnue?s? \(pas de [^\)]+\))\)?/i, "") # rubocop:disable Layout/LineLength
          &.presence
      # rubocop:enable Style/SafeNavigationChainLength
    end

    def self.configured?
      raise NotImplementedError
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def self.extract_numbered_list(text) # rubocop:disable Metrics/MethodLength
      parts = text.split(/^\s*\d+\.\s+/).keep_if { it.start_with?("**") }
      parts.each_with_index.map do |part, index|
        match = part.match(/^\*\*(?<label>.*?)\*\*\s*: *\n*(?:\s*-\s*)?(?<value>.*)$/m)
        raise ResultError, "Parsing numbered list inside part: #{part}" unless match

        detected_separator = [
          /\n+\s*-\s*/,
          %r{/},
          /,/
        ].detect { match[:value].match? it } || ","

        {
          number: Integer(index + 1),
          label: match[:label],
          value: clean_value(match[:value])&.split(/\s*#{detected_separator}\s*/)&.map(&:strip)
        }
      end.sort_by { it.fetch(:number) } # rubocop:disable Style/MultilineBlockChain
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    def self.extract_json(text)
      text[/(\{.+\})/im, 1]
    end

    def self.extract_jsx(text)
      text[/(\{.+\})/im, 1] if text&.match?(/```jsx\n/i)
    end

    def self.sort_models(models)
      models.sort_by do |model|
        # Extract the size (e.g., "8B", "70B") and convert to an integer
        size = model.match(/-(\d+)B-/i)&.to_a&.last.to_i

        # Prioritize meta-llama models (-1 for meta-llama, 0 for others)
        priority = model.include?("meta-llama") ? -1 : 0

        # Sort by priority first, then by size in descending order (negative size)
        [priority, -size]
      end
    end

    def chat_completion(text)
      raise NotImplementedError
    end

    # rubocop:disable Metrics/AbcSize
    def extract_result(content) # rubocop:disable Metrics/MethodLength
      case result_format
      when :numbered_list
        @read_attributes = TrackingHash.nilify_empty_values(
          self.class.extract_numbered_list(content).to_h { [it.fetch(:label), it.fetch(:value)] }
        )
      else # :json
        content_jsx_result = self.class.extract_jsx(content)
        if content_jsx_result
          @read_attributes = eval(content_jsx_result.gsub(/: +null/i, ": nil")) # rubocop:disable Security/Eval
        else
          content_json_result = self.class.extract_json(content)
          @read_attributes = begin
            TrackingHash.nilify_empty_values(
              JSON.parse(content_json_result, symbolize_names: true)
            )
          rescue JSON::ParserError
            raise ResultError, "Parsing JSON inside content: #{content_json_result}"
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
