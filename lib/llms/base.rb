# frozen_string_literal: true

module Llms
  # Base API client
  class Base
    class ResultError < StandardError; end

    attr_reader :prompt

    def initialize(prompt)
      @prompt = prompt
    end

    def self.configured?
      raise NotImplementedError
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
  end
end
