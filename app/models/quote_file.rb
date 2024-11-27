# frozen_string_literal: true

require "mime/types"

# Class to store uploaded Quote files, raw like
class QuoteFile < ApplicationRecord
  has_one_attached :file

  validates :filename, presence: true
  validates :file, presence: true
  validates :hexdigest, presence: true, uniqueness: true

  validate :correct_file_type
  validate :file_size_validation

  def self.find_or_create_file(tempfile, filename)
    hexdigest = hexdigest_for_file(tempfile)

    find_by(hexdigest: hexdigest) || create!(
      filename: filename,
      file: tempfile_to_file(tempfile),
      hexdigest: hexdigest,
      uploaded_at: Time.current
    )
  end

  def self.hexdigest_for_file(tempfile)
    Digest::SHA256.file(tempfile).hexdigest
  end

  def self.tempfile_to_file(tempfile)
    return unless tempfile

    content_type = MIME::Types.type_for(tempfile.path).first.content_type

    {
      io: tempfile,
      filename: File.basename(tempfile.path),
      content_type: content_type
    }
  end

  private

  def correct_file_type
    return unless file.attached? && !file.content_type.in?(%w[application/pdf])

    errors.add(:file, "must be a PDF")
  end

  def file_size_validation
    return unless file.attached? && file.blob.byte_size > 50.megabytes

    errors.add(:file, "is too large. Maximum size is 50MB.")
  end
end
