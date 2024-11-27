# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes by asking questions via LLM prompt online services
  class Qa < Text
    def read_attributes
      return super if text.blank?

      super.merge(llm_result)
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
