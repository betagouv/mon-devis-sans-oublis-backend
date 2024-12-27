# frozen_string_literal: true

# Store user feedback for a quote check
class QuoteCheckFeedback < ApplicationRecord
  belongs_to :quote_check

  # Global feedback
  validates :rating,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 },
            if: -> { validation_error_details_id.blank? }

  # Detail feedback
  validates :validation_error_details_id, presence: true, if: -> { rating.blank? }
  validates :is_helpful, inclusion: { in: [true, false] }, if: -> { validation_error_details_id.present? }

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :comment, length: { maximum: 1_000 }

  before_validation :check_validation_error_details_id, if: -> { validation_error_details_id.present? }

  private

  def check_validation_error_details_id
    return if quote_check&.validation_error_details&.any? { |ved| ved.fetch("id") == validation_error_details_id }

    errors.add(:validation_error_details_id, "is invalid")
  end
end
