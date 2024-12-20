# frozen_string_literal: true

require "swagger_helper"

describe "Devis API" do
  path "/quote_checks/{quote_check_id}/feedbacks" do
    # TODO: i18n?
    post "Déposer un retour" do
      tags "Devis"
      security [basic_auth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :quote_check_id, in: :path, type: :string
      parameter name: :quote_check_feedback, in: :body, schema: {
        type: :object,
        properties: {
          validation_error_details_id: { type: :string, nullable: false },
          is_helpful: { type: :boolean, nullable: false },
          comment: {
            type: :string,
            nullable: true,
            maxLength: QuoteCheckFeedback.validators_on(:comment).detect do |validator|
              validator.is_a?(ActiveModel::Validations::LengthValidator)
            end&.options&.[](:maximum)
          }
        },
        required: %w[validation_error_details_id is_helpful]
      }

      let(:quote_check_id) { create(:quote_check, :invalid).id }
      let(:quote_check_feedback) do
        build(:quote_check_feedback, quote_check: QuoteCheck.find(quote_check_id)).attributes
      end

      response "201", "Retour téléversé" do
        schema "$ref" => "#/components/schemas/quote_check_feedback"

        # See https://github.com/rswag/rswag/issues/316
        let(:Authorization) { basic_auth_header.fetch("Authorization") } # rubocop:disable RSpec/VariableName

        run_test!
      end

      response "422", "missing params" do
        schema "$ref" => "#/components/schemas/api_error"

        let(:quote_check_feedback) { build(:quote_check_feedback).attributes.merge("is_helpful" => nil) }

        let(:Authorization) { basic_auth_header.fetch("Authorization") } # rubocop:disable RSpec/VariableName

        run_test!
      end
    end
  end
end
