# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Private data attributes by asking questions via LLM prompt online services
  class PrivateDataQa < Text
    VERSION = "0.0.1"

    attr_reader :read_attributes, :result

    def read
      return {} if text.blank?

      llm_read_attributes
    end

    def version
      self.class::VERSION
    end

    private

    def llm_read_attributes
      return unless Llms::Albert.configured?

      llm = Llms::Albert.new(prompt, result_format: :numbered_list)
      begin
        llm.chat_completion(text)
      rescue Net::ReadTimeout, Llms::Albert::ResultError => e
        ErrorNotifier.notify(e)
      end

      @read_attributes = TrackingHash.new(llm.read_attributes)
      @result = llm.result

      read_attributes
    end

    def prompt
      Rails.root.join("lib/quote_reader/prompts/private_data.txt").read
    end
  end
end