# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes by asking questions via LLM prompt online services
  class Qa < Text
    VERSION = "0.0.1"

    def read
      return {} if text.blank?

      @read_attributes = llm_result
    end

    def version
      self.class::VERSION
    end

    private

    def llm_result
      return Llms::Mistral.new(prompt).chat_completion(text) if Llms::Mistral.configured?

      {}
    end

    def prompt
      Rails.root.join("lib/quote_reader/prompt_qa.txt").read
    end
  end
end
