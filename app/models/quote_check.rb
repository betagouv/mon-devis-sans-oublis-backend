# frozen_string_literal: true

# QuoteCheck represents a submission of a quote to be checked.
class QuoteCheck < ApplicationRecord
  belongs_to :file, class_name: "QuoteFile"

  validates :profile, presence: true, inclusion: { in: QuoteChecksController::PROFILES }

  validates :started_at, presence: true

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end
end
