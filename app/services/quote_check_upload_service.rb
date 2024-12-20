# frozen_string_literal: true

# This class is responsible for creating the quote by the upload.
class QuoteCheckUploadService
  attr_reader :tempfile, :filename, :profile,
              :parent_id,
              :quote_check

  def initialize(tempfile, filename, profile, parent_id: nil)
    @tempfile = tempfile
    @filename = filename
    @profile = profile

    @parent_id = parent_id
  end

  def upload
    quote_file = QuoteFile.find_or_create_file(tempfile, filename)

    @quote_check = QuoteCheck.create!(
      file: quote_file,
      profile: profile,
      started_at: Time.current,

      parent_id: parent_id
    )
  end
end
