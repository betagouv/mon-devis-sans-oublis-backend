# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes by asking questions via LLM prompt online services
  class Qa < Text
    DEFAULT_LLM = "mistral"
    VERSION = "0.0.1"

    attr_reader :read_attributes, :result

    def read(llm: nil)
      return {} if text.blank?

      llm_read_attributes(llm || DEFAULT_LLM)
    end

    def version
      self.class::VERSION
    end

    private

    def llm_read_attributes(llm) # rubocop:disable Metrics/MethodLength
      llm_klass = "Llms::#{llm.capitalize}".constantize
      return unless llm_klass.configured?

      mistral = llm_klass.new(prompt)
      begin
        mistral.chat_completion(text)
      rescue llm_klass::ResultError => e
        ErrorNotifier.notify(e)
      end

      @read_attributes = TrackingHash.new(mistral.read_attributes)
      @result = mistral.result

      read_attributes
    end

    def prompt
      Rails.root.join("lib/quote_reader/prompts/qa.txt").read
    end
  end
end
