# frozen_string_literal: true

# Controller for the Quotes resource
class QuotesController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? && action_name == "check" }

  PROFILES = %w[artisan particulier mandataire conseiller].freeze

  before_action :set_profile, only: %i[check]

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def check
    upload_file = params[:quote_file]

    # Default web form
    if request.format.html? && upload_file.blank?
      @quote_attributes = QuoteCheckService.default_quote_attributes
      render :check
      return
    end

    if upload_file.present?
      @quote_check = QuoteCheckService.new(
        upload_file.tempfile, upload_file.original_filename, params[:profile]
      ).check
      @quote_attributes = @quote_check.read_attributes
      @quote_valid = @quote_check.quote_valid?
      @quote_errors = @quote_check.validation_errors
    end

    unless @quote_attributes
      head :bad_request
      return
    end

    http_status = @quote_valid ? :ok : :unprocessable_entity
    respond_to do |format|
      format.html { render :check, status: http_status }
      format.json do
        render json: {
          valid: @quote_valid,
          errors: @quote_errors
        }, status: http_status
      end
    end
  rescue QuoteReader::ReadError => e
    @quote_errors = [e.message]
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def profiles
    @profiles = PROFILES

    respond_to do |format|
      format.html
      format.json { render json: @profiles }
    end
  end

  protected

  def set_profile
    @profile ||= PROFILES.detect { |profile| profile == params[:profile].to_sym } if params[:profile]
  end
end
