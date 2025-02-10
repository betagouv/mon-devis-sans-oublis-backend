# frozen_string_literal: true

module Api
  module V1
    # Controller for QuoteChecks API
    class QuoteChecksController < BaseController
      before_action :authorize_request, except: :metadata
      before_action :quote_check, only: %i[show]

      def show
        # Force to use async way by using show to get other fields
        render json: quote_check_json
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def create
        upload_file = quote_check_params[:file]

        if upload_file.blank?
          render json: { error: "No file uploaded" }, status: :unprocessable_entity
          return
        end

        quote_check_service = QuoteCheckService.new(
          upload_file.tempfile, upload_file.original_filename,
          quote_check_params[:profile],
          metadata: quote_check_params[:metadata],
          parent_id: quote_check_params[:parent_id]
        )
        @quote_check = quote_check_service.quote_check

        QuoteCheckCheckJob.perform_later(@quote_check.id) # Might be time consuming so make it async with background job
        # @quote_check = QuoteCheckCheckJob.new.perform(@quote_check.id) # Local debug

        QuoteCheckMailer.created(@quote_check).deliver_later

        render json: quote_check_json(@quote_check), status: :created
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def metadata
        render json: I18n.t("quote_checks.metadata").to_json
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.quote_check_json(quote_check = nil)
        json_hash = quote_check.attributes.merge({ # Warning: attributes has stringifed keys, so use it too
                                                   "status" => quote_check.status,
                                                   "errors" => quote_check.validation_errors,
                                                   "error_details" => quote_check.validation_error_details,
                                                   "error_messages" => quote_check.validation_errors&.index_with do
                                                     I18n.t("quote_validator.errors.#{it}")
                                                   end,
                                                   "filename" => quote_check.filename,

                                                   "gestes" => quote_check.read_attributes&.fetch("gestes", nil) # rubocop:disable Style/SafeNavigationChainLength
                                                                &.map&.with_index do |geste, geste_index|
                                                                  geste.slice("intitule").merge(
                                                                    "id" => QuoteValidator::Base.geste_index(
                                                                      quote_check.id, geste_index
                                                                    )
                                                                  )
                                                                end
                                                 })
        return json_hash if Rails.env.development?

        json_hash.slice(
          "id", "status", "profile", "metadata",
          "valid", "errors", "error_details", "error_messages",
          "parent_id",
          "filename",
          "gestes",
          "finished_at"
        ).compact
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      protected

      def quote_check_json(quote_check_provided = nil)
        self.class.quote_check_json(quote_check_provided || quote_check)
      end

      def quote_check
        @quote_check ||= QuoteCheck.find(params[:id])
      end

      def quote_check_params
        params.permit(:file, :metadata, :profile, :parent_id)
      end
    end
  end
end
