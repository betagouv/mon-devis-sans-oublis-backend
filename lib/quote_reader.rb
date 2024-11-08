# frozen_string_literal: true

require "pdf-reader"

# Read Quote from PDF file to extract Quote attributes
class QuoteReader
  class ReadError < StandardError; end

  attr_reader :filepath, :quote_text

  def initialize(filepath)
    @filepath = filepath
  end

  def read_attributes
    @quote_text = extract_text_from_pdf(filepath)

    {
      quote_number: find_quote_number(quote_text),
      rge_number: find_rge_number(quote_text),
      siret_number: find_siret_number(quote_text),

      full_text: quote_text
    }
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError,
         StandardError
    raise parse_error(error)
  end

  private

  def parse_error(error)
    error_message = case error
                    when PDF::Reader::MalformedPDFError
                      "Failed to parse PDF: The file may be corrupted."
                    when PDF::Reader::UnsupportedFeatureError
                      "Failed to parse PDF: An unsupported feature was used in the PDF."
                    when StandardError
                      "An error occurred: #{e.message}"
                    end

    ReadError.new(error_message)
  end

  def find_quote_number(text)
    text[/DEVIS\s+N°\s*(\d+)/i, 1] if text
  end

  def find_rge_number(text)
    text[/RGE\s+N°\s*(\d+)/i, 1] if text
  end

  def find_siret_number(text)
    text[/SIRET\s*:\s*(\d{3}\s*\d{3}\s*\d{3}\s*\d{5})/i, 1]&.gsub(/\s/, "") if text
  end

  def extract_text_from_pdf(pdf_path)
    reader = PDF::Reader.new(pdf_path)
    text = reader.pages.map(&:text)

    text.join("\n") # Join all pages text into a single string, separated by new lines
  end
end
