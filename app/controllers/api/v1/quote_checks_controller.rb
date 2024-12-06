# frozen_string_literal: true

module Api
  module V1
    # Controller for QuoteChecks API
    class QuoteChecksController < BaseController
      before_action :quote_check, only: %i[show]

      def show
        render json: quote_check_json
      end

      # rubocop:disable Metrics/MethodLength
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
        @quote_check = quote_check_service.check # Might be time consuming, TODO: move to background job is needed

        QuoteCheckMailer.created(@quote_check).deliver_later

        render json: quote_check_json(@quote_check)
      end
      # rubocop:enable Metrics/MethodLength

      protected

      def quote_check
        @quote_check ||= QuoteCheck.find(params[:id])
      end

      def quote_check_params
        params.require(:quote_check).permit(:file, :profile)
      end

      def quote_check_json(quote_check_provided = nil)
        object = quote_check_provided || quote_check
        object.attributes.merge({
                                  status: object.status,
                                  valid: object.quote_valid?,
                                  errors: object.validation_errors,
                                  error_messages: object.validation_errors&.index_with do |error_key|
                                    I18n.t("quote_validator.errors.#{error_key}")
                                  end
                                })
      end
    end
  end
end
