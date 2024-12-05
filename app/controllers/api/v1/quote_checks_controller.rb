# frozen_string_literal: true

module Api
  module V1
    # Controller for QuoteChecks API
    class QuoteChecksController < BaseController
      before_action :quote_check, only: %i[show]

      def show
        render json: quote_check_json
      end

      def create
        upload_file = quote_check_params[:file]

        if upload_file.blank?
          render json: { error: "No file uploaded" }, status: :unprocessable_entity
          return
        end

        @quote_check = QuoteCheckService.new(
          upload_file.tempfile, upload_file.original_filename, quote_check_params[:profile]
        ).check

        QuoteCheckMailer.created(@quote_check).deliver_later

        render json: quote_check_json(@quote_check)
      end

      protected

      def quote_check
        @quote_check ||= QuoteCheck.find(params[:id])
      end

      def quote_check_params
        params.require(:quote_check).permit(:file, :profile)
      end

      def quote_check_json(quote_check_provided = nil)
        (quote_check_provided || quote_check)
          .attributes.merge({
                              valid: quote_check.quote_valid?,
                              errors: quote_check.validation_errors,
                              error_messages: quote_check.validation_errors&.index_with do |error_key|
                                I18n.t("quote_validator.errors.#{error_key}")
                              end
                            })
      end
    end
  end
end
