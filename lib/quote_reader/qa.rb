# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes by asking questions via LLM prompt online services
  class QA < Text
    def read_attributes
      return super if text.blank?

      super.merge(call_llm)
    end

    private

    def call_llm
      # TODO: API
    end

    def prompt
      File.read("prompt_qa.txt")
    end
  end
end
