# frozen_string_literal: true

# Controller for the Quotes resource
class QuotesController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? && action_name == "check" }

  PROFILES = %i[artisan particulier mandataire conseiller].freeze

  before_action :set_profile, only: %i[check]

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def check
    @quote_errors = []

    @quote_attributes = if params[:quote_file].present?
                          begin
                            file_to_attributes(params[:quote_file])
                          rescue QuoteReader::ReadError
                            @quote_errors << "file_reading_error"
                          end
                        else
                          default_quote_attributes
                        end
    unless @quote_attributes
      head :bad_request
      return
    end

    @quote_validation = quote_validation(@quote_attributes)
    @quote_valid = @quote_validation.valid?
    @quote_errors += @quote_validation.errors

    temp_file_path = params[:quote_file]&.tempfile&.path
    @quote_preview_path = QuoteReader::Preview.new(temp_file_path).generate_preview if temp_file_path

    http_status = @quote_valid ? :ok : :unprocessable_entity
    respond_to do |format|
      format.html { render :check, status: http_status }
      format.json do
        render json: {
          valid: @quote_valid,
          errors: @quote_errors,
          preview: @quote_preview_path
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

  def quote_fields
    quote_validation = QuoteValidator::Global.new({})
    quote_validation.validate!
    quote_validation.fields
  end

  def default_quote_attributes(fields = quote_fields)
    fields.to_h do |field|
      if field.is_a?(Hash)
        [field.keys.first, default_quote_attributes(field.values.first)]
      elsif field.is_a?(Array)
        field
      else
        [field, nil]
      end
    end
  end

  def file_to_attributes(uploaded_file)
    temp_file_path = uploaded_file.tempfile.path

    QuoteReader::Global.new(temp_file_path).read_attributes
  end

  def quote_validation(quote_attributes)
    QuoteValidator::Global.new(quote_attributes).tap(&:validate!)
  end
end
