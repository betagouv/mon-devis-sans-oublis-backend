# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes
  class Text
    attr_reader :text, :read_attributes

    def initialize(text)
      @text = text
    end

    def read
      @read_attributes = {
        full_text: text
      }
    end
  end
end
