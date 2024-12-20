# frozen_string_literal: true

# Store user feedback for a quote check
class QuoteCheckFeedback < ApplicationRecord
  belongs_to :quote_check

  validates :validation_error_details_id, presence: true
  validates :is_helpful, inclusion: { in: [true, false] }
  validates :comment, length: { maximum: 1_000 }

  before_validation :check_validation_error_details_id

  def check_validation_error_details_id
    return if quote_check&.validation_error_details&.any? { |ved| ved.fetch("id") == validation_error_details_id }

    errors.add(:validation_error_details_id, "is invalid")
  end
end
