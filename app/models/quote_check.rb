# frozen_string_literal: true

# QuoteCheck represents a submission of a quote to be checked.
class QuoteCheck < ApplicationRecord
  belongs_to :file, class_name: "QuoteFile"
  belongs_to :parent, class_name: "QuoteFile", optional: true

  has_many :feedbacks, class_name: "QuoteCheckFeedback", dependent: :destroy
  has_many :children, class_name: "QuoteFile", foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify

  STATUSES = %w[pending valid invalid].freeze

  PROFILES = %w[artisan particulier mandataire conseiller].freeze
  validates :profile, presence: true, inclusion: { in: PROFILES }

  validates :started_at, presence: true

  validate :validation_errors_as_array, if: -> { validation_errors.present? || validation_error_details.present? }

  def frontend_webapp_url
    return unless id

    profile_path = case profile
                   when "artisan" then "artisan"
                   when "conseiller" then "conseiller"
                   when "mandataire" then "mandataire"
                   when "particulier" then "particulier"
                   else
                     raise NotImplementedError, "Unknown path for profile: #{profile}"
                   end

    URI.join("#{ENV.fetch('FRONTEND_APPLICATION_HOST')}/", "#{profile_path}/", "televersement/", id).to_s
  end

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end

  def status
    return "pending" if finished_at.blank?

    validation_errors.blank? ? "valid" : "invalid"
  end

  def validation_errors_as_array
    errors.add(:validation_errors, "must be an array") if validation_errors && !validation_errors.is_a?(Array)
    return unless validation_error_details && !validation_error_details.is_a?(Array)

    errors.add(:validation_error_details, "must be an array")
  end
end
