# frozen_string_literal: true

require "mime/types"

# Class to store uploaded Quote files, raw like
# TODO: clear if we keep storing file in double in the data binary field,
# AND also via active_storage-postgresq gem specific table via Postgres File OID
# See .find_or_create_file and #content methods
class QuoteFile < ApplicationRecord
  has_one_attached :file
  has_many :quote_checks, dependent: :nullify, inverse_of: :file

  # Do not limit on content_type: ["application/pdf"]
  # So check can manualy review them
  validates :filename, presence: true
  validates :content_type, presence: true
  validates :hexdigest, presence: true, uniqueness: true # checksum like

  validates :data, presence: true
  validates :file, attached: true, size: { less_than: 50.megabytes }

  # rubocop:disable Metrics/MethodLength
  def self.find_or_create_file(tempfile, filename)
    hexdigest = hexdigest_for_file(tempfile)
    file = tempfile_to_file(tempfile)

    existing_quote_file = find_by(hexdigest: hexdigest)
    return existing_quote_file if existing_quote_file

    new(
      filename: filename,
      content_type: file[:content_type],
      hexdigest: hexdigest,
      uploaded_at: Time.current
    ).tap do |new_quote_file|
      tempfile.rewind
      new_quote_file.data = tempfile.read

      tempfile.rewind
      new_quote_file.file.attach(io: tempfile, filename: filename) # File.basename(tempfile.path)

      new_quote_file.save!
    end
  end
  # rubocop:enable Metrics/MethodLength

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

  def local_path
    ActiveStorage::Blob.service.path_for(file.key) if file
  end

  def content
    data # OR file&.download
  end
end
