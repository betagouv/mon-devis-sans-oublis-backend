# frozen_string_literal: true

# This class is responsible for creating the quote by the upload.
class QuoteCheckUploadService
  attr_reader :tempfile, :filename, :profile,
              :quote_check

  def initialize(tempfile, filename, profile)
    @tempfile = tempfile
    @filename = filename
    @profile = profile
  end

  def upload
    quote_file = QuoteFile.find_or_create_file(tempfile, filename)

    @quote_check = QuoteCheck.create!(
      file: quote_file,
      profile: profile,
      started_at: Time.current
    )
  end
end
