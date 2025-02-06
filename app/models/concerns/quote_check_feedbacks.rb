# frozen_string_literal: true

# Add feedbacks
module QuoteCheckFeedbacks
  extend ActiveSupport::Concern

  included do
    has_many :feedbacks, class_name: "QuoteCheckFeedback", dependent: :destroy

    validate :expected_validation_errors_as_array, if: -> { expected_validation_errors.present? }

    scope :with_expected_value, -> { where.not(expected_validation_errors: nil) }
  end

  def expected_validation_errors_as_array
    return unless expected_validation_errors && !expected_validation_errors.is_a?(Array)

    errors.add(:expected_validation_errors,
               "must be an array")
  end
end
