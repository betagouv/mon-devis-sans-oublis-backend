# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes by asking questions via LLM prompt online services
  class Qa < Text
    VERSION = "0.0.1"

    attr_reader :read_attributes, :result

    def read
      return {} if text.blank?

      @read_attributes = llm_read_attributes
    end

    def version
      self.class::VERSION
    end

    private

    def llm_read_attributes
      return unless Llms::Mistral.configured?

      mistral = Llms::Mistral.new(prompt)
      begin
        mistral.chat_completion(text)
      rescue ResultError => e
        ErrorNotifier.notify(e)
      end

      @read_attributes = mistral.read_attributes
      @result = mistral.result
    end

    def prompt
      Rails.root.join("lib/quote_reader/prompt_qa.txt").read
    end
  end
end
