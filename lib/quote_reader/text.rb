# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes
  class Text
    attr_reader :text

    def initialize(text)
      @text = text
    end

    def read_attributes
      {
        full_text: text
      }
    end
  end
end
