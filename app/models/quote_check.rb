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

  delegate :filename, to: :file, allow_nil: true

  # Returns a float number in €
  def cost
    return unless qa_result&.key?("usage")

    usage = qa_result.fetch("usage")
    Llms::Mistral.usage_cost_price(
      completion_tokens: usage.fetch("completion_tokens"),
      prompt_tokens: usage.fetch("prompt_tokens")
    )
  end

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

  def processing_time
    return unless finished_at

    finished_at - started_at
  end

  def qa_llm
    case qa_result&.dig("id")
    when /\Achatcmpl-/
      "Albert"
    else
      "Mistral" if qa_model&.start_with?("mistral-")
    end
  end

  def qa_model
    qa_result&.dig("model")
  end

  # valid? is already used by the framework
  def quote_valid?
    validation_version.present? && validation_errors.blank?
  end

  def status
    return "pending" if finished_at.blank?

    validation_errors.blank? ? "valid" : "invalid"
  end

  # Sum of prompt and completion tokens
  def tokens_count
    return unless qa_result&.key?("usage")

    qa_result.fetch("usage").fetch("total_tokens")
  end

  def validation_errors_as_array
    errors.add(:validation_errors, "must be an array") if validation_errors && !validation_errors.is_a?(Array)
    return unless validation_error_details && !validation_error_details.is_a?(Array)

    errors.add(:validation_error_details, "must be an array")
  end
end
