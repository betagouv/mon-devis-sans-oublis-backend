# frozen_string_literal: true

module Api
  module V1
    # Controller for QuoteChecks API
    class QuoteChecksController < BaseController
      before_action :authorize_request
      before_action :quote_check, only: %i[show]

      def show
        # Force to use async way by using show to get other fields
        render json: quote_check_json
      end

      def create
        upload_file = quote_check_params[:file]

        if upload_file.blank?
          render json: { error: "No file uploaded" }, status: :unprocessable_entity
          return
        end

        quote_check_service = QuoteCheckService.new(
          upload_file.tempfile, upload_file.original_filename, quote_check_params[:profile]
        )
        @quote_check = quote_check_service.quote_check

        # @quote_check = quote_check_service.check # Might be time consuming, TODO: move to background job is needed
        QuoteCheckCheckJob.perform_later(@quote_check.id)

        QuoteCheckMailer.created(@quote_check).deliver_later

        render json: quote_check_json(@quote_check), status: :created
      end

      protected

      def quote_check
        @quote_check ||= QuoteCheck.find(params[:id])
      end

      def quote_check_params
        params.permit(:file, :profile)
      end

      # rubocop:disable Metrics/MethodLength
      def quote_check_json(quote_check_provided = nil)
        object = quote_check_provided || quote_check
        json_hash = object.attributes.merge({ # Warning: attributes has stringifed keys, so use it too
                                              "status" => object.status,
                                              "valid" => object.quote_valid?,
                                              "errors" => object.validation_errors,
                                              "error_details" => object.validation_error_details,
                                              "error_messages" => object.validation_errors&.index_with do |error_key|
                                                I18n.t("quote_validator.errors.#{error_key}")
                                              end
                                            })
        return json_hash if Rails.env.development?

        json_hash.slice(
          "id", "status", "profile",
          "valid", "errors", "error_details", "error_messages"
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
