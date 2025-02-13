# frozen_string_literal: true

# Add edits
module QuoteCheckEdits
  extend ActiveSupport::Concern

  MAX_COMMENT_LENGTH = 1_000
  MAX_EDITION_REASON_LENGTH = 255
  VALIDATION_ERROR_DELETION_REASONS = %w[
    information_not_present
    not_used
  ].freeze

  included do
    validates :comment, length: { maximum: MAX_COMMENT_LENGTH }

    before_validation :format_validation_error_edits
    validate :validation_error_edits_data

    scope :with_edits, -> { where.not(validation_error_edits: nil) }
  end

  def delete_validation_error_detail!(error_id, reason: nil)
    self.validation_error_edits ||= {}
    validation_error_edits[error_id] = {
      deleted: true,
      deleted_at: Time.zone.now,
      reason: reason&.first(QuoteCheck::MAX_EDITION_REASON_LENGTH)
    }

    save!
  end

  def format_validation_error_edits
    self.validation_error_edits = validation_error_edits&.presence
    return unless validation_error_edits

    self.validation_error_edits = JSON.parse(validation_error_edits) if validation_error_edits.is_a?(String)
    self.validation_error_edits = validation_error_edits.transform_values(&:presence).compact # Remove empty values

    validation_error_edits
  end

  def readd_validation_error_detail!(validation_error_id)
    self.validation_error_edits = validation_error_edits&.except(validation_error_id).presence

    save!
  end

  def validation_error_edits_data
    return unless validation_error_edits

    validation_error_edits.each do |error_id, edit|
      next unless edit

      if validation_error_details.none? { it.fetch("id") == error_id }
        errors.add(:validation_error_edits, "erreur #{error_id} inconnue")
      end

      if edit["reason"].to_s.length > MAX_EDITION_REASON_LENGTH
        errors.add(:validation_error_edits, "reason in #{error_id} exceeds #{MAX_EDITION_REASON_LENGTH} chars")
      end
    end
  end
end
