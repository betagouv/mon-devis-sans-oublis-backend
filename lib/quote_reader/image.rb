# frozen_string_literal: true

require "mini_magick"
require "rtesseract"
require "stringio"
require "tempfile"

module QuoteReader
  # Read Quote from image file to extract Quote text
  class Image
    class ReadError < QuoteReader::ReadError; end

    attr_reader :content, :content_type, :text

    def initialize(content, content_type)
      @content = content
      @content_type = content_type
    end

    def extract_text
      # Do not use blank? as it contains non UTF-8 binary data
      raise ReadError, "No content provided" if content.nil? || content.empty? # rubocop:disable Rails/Blank

      @text = extract_text_from_image # TODO: fix_french_characters if needed
    rescue StandardError => e
      raise parse_error(e)
    end

    private

    def parse_error(error)
      ReadError.new("An error occurred: #{error.message}")
    end

    # Using Tesseract OCR
    def extract_text_from_image
      extension = determine_extension

      Tempfile.open(["ocr_image", extension]) do |tempfile|
        tempfile.binmode
        tempfile.write(content)
        tempfile.rewind

        # Convert to PNG (if needed) to improve OCR accuracy
        processed_image = MiniMagick::Image.open(tempfile.path)
        processed_image.format("png") unless extension == ".png"

        RTesseract.new(processed_image.path, lang: "fra").to_s # French language
      end
    end

    def determine_extension
      case content_type
      when "image/jpeg", "image/jpg" then ".jpg"
      when "image/tiff" then ".tiff"
      # when "image/png" # Default fallback
      else ".png"
      end
    end
  end
end
