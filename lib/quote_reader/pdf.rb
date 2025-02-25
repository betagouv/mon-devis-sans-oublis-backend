# frozen_string_literal: true

require "pdf-reader"

module QuoteReader
  # Read Quote from PDF file to extract Quote text
  class Pdf
    class ReadError < QuoteReader::ReadError; end

    attr_reader :content, :text

    def initialize(content)
      @content = content
    end

    def extract_text
      @text = fix_french_characters(extract_text_from_pdf)
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError,
           StandardError => e
      raise parse_error(e)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def fix_french_characters(text)
      corrections = {
        "ÿ" => " ",
        "oe" => "œ",
        "Ã©" => "é",
        "Ã¨" => "è",
        "Ãª" => "ê",
        "Ã´" => "ô",
        "Ã " => "à",
        "Ã§" => "ç",
        "â" => "'",
        "â" => "-",
        "â¬" => "€"
      }
      corrections.each { |original, replacement| text.gsub!(original, replacement) }

      text
    end
    # rubocop:enable Metrics/MethodLength

    def parse_error(error)
      error_message = case error
                      when PDF::Reader::MalformedPDFError
                        "Failed to parse PDF: The file may be corrupted."
                      when PDF::Reader::UnsupportedFeatureError
                        "Failed to parse PDF: An unsupported feature was used in the PDF."
                      when StandardError
                        "An error occurred: #{error.message}"
                      end

      ReadError.new(error_message)
    end

    def extract_text_from_pdf
      io = StringIO.new(content)

      reader = PDF::Reader.new(io)
      raw_text = reader.pages.map(&:text)

      raw_text.join("\n") # Join all pages text into a single string, separated by new lines
    end
  end
end
