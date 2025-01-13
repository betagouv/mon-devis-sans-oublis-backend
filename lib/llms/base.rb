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

    def self.configured?
      raise NotImplementedError
    end

    # rubocop:disable Metrics/AbcSize
    def self.extract_numbered_list(text) # rubocop:disable Metrics/MethodLength
      pattern = /^(?<number>\d+)\.\s.*?\*\*(?<title>.*?)\*\*\s*: *(?<value>.*)$/
      matches = text.scan(pattern)

      matches.map do |match|
        detected_separator = ["/", ","].detect { match[2].include? it } || ","

        {
          number: Integer(match[0]),
          label: match[1],
          value: match[2].gsub(/\(?Non (mentionné|disponible)\)?/i, "")
                         .presence&.split(/\s*#{detected_separator}\s*/)
        }
      end.sort_by { it.fetch(:number) } # rubocop:disable Style/MultilineBlockChain
    end
    # rubocop:enable Metrics/AbcSize

    def self.extract_json(text)
      text[/(\{.+\})/im, 1]
    end

    def self.extract_jsx(text)
      text[/(\{.+\})/im, 1] if text&.match?(/```jsx\n/i)
    end

    def self.nilify_empty_values(value)
      case value
      when Hash
        value.transform_values { nilify_empty_values(it) }
      when Array
        value.map { nilify_empty_values(it) }
      when value.presence
        value
      end
    end

    def chat_completion(text)
      raise NotImplementedError
    end

    # rubocop:disable Metrics/AbcSize
    def extract_result(content) # rubocop:disable Metrics/MethodLength
      case result_format
      when :numbered_list
        @read_attributes = nilify_empty_values(
          self.class.extract_numbered_list(content).to_h { [it.fetch(:label), it.fetch(:value)] }
        )
      else # :json
        content_jsx_result = self.class.extract_jsx(content)
        if content_jsx_result
          @read_attributes = eval(content_jsx_result.gsub(/: +null/i, ": nil")) # rubocop:disable Security/Eval
        else
          content_json_result = self.class.extract_json(content)
          @read_attributes = begin
            nilify_empty_values(
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
