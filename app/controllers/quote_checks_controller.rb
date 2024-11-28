# frozen_string_literal: true

# Controller for the Quotes resource
class QuoteChecksController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? && action_name == "new" }
  before_action :quote_check, only: %i[show edit update]

  PROFILES = %w[artisan particulier mandataire conseiller].freeze

  before_action :set_profile, only: %i[new]

  def show
    render_show
  end

  # rubocop:disable Metrics/MethodLength
  def new
    upload_file = params[:quote_file]

    # Default web form
    if request.format.html? && upload_file.blank?
      @quote_attributes = QuoteCheckService.default_quote_attributes
      render :show
      return
    end

    if upload_file.present?
      @quote_check = QuoteCheckService.new(
        upload_file.tempfile, upload_file.original_filename, params[:profile]
      ).check
    end

    render_show
  end

  # rubocop:enable Metrics/MethodLength
  def edit
    render_show
  end

  def update
    render_show
  end

  def profiles
    @profiles = PROFILES

    respond_to do |format|
      format.html
      format.json { render json: @profiles }
    end
  end

  protected

  def quote_check
    @quote_check ||= QuoteCheck.find(params[:id])
  end

  # rubocop:disable Metrics/MethodLength
  def render_show
    set_quote_check_results

    unless @quote_attributes
      head :bad_request
      return
    end

    http_status = @quote_valid ? :ok : :unprocessable_entity
    respond_to do |format|
      format.html { render :show, status: http_status }
      format.json do
        render json: {
          valid: @quote_valid,
          errors: @quote_errors
        }, status: http_status
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def set_profile
    @profile ||= PROFILES.detect { |profile| profile == params[:profile].to_sym } if params[:profile]
  end

  def set_quote_check_results
    @quote_attributes = quote_check.read_attributes
    @quote_valid = quote_check.quote_valid?
    @quote_errors = quote_check.validation_errors
  end
end
