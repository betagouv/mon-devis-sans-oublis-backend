# frozen_string_literal: true

module Llms
  # Base API client
  class Base
    class ResultError < StandardError; end

    attr_reader :prompt, :result_format

    def initialize(prompt, result_format: :json)
      @prompt = prompt
      @result_format = result_format
    end

    def self.configured?
      raise NotImplementedError
    end

    def self.extract_numbered_list(text)
      pattern = /^\d+\.\s\*\*(.*?)\*\*\s?:\s?(.*)$/ 
      matches = text.scan(pattern)

      matches.map { |match| { number: match[0], value: match[1] } }
    end

    def self.extract_json(text)
      text[/(\{.+\})/im, 1]
    end

    def self.extract_jsx(text)
      text[/(\{.+\})/im, 1] if text&.match?(/```jsx\n/i)
    end

    def chat_completion(text)
      raise NotImplementedError
    end

    def extract_result(content) # rubocop:disable Metrics/MethodLength
      case result_format
      when :numbered_list
        @read_attributes = self.class.extract_numbered_list(content)
      else # :json
        content_jsx_result = self.class.extract_jsx(content)
        if content_jsx_result
          @read_attributes = eval(content_jsx_result.gsub(/: +null/i, ": nil")) # rubocop:disable Security/Eval
        else
          content_json_result = self.class.extract_json(content)
          @read_attributes = begin
            JSON.parse(content_json_result, symbolize_names: true)
          rescue JSON::ParserError
            raise ResultError, "Parsing JSON inside content: #{content_json_result}"
          end
        end
      end
    end
  end
end
