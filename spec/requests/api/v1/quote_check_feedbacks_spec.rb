# frozen_string_literal: true

# spec/controllers/posts_controller_spec.rb
require "rails_helper"

RSpec.describe "/api/v1/quote_checks/:quote_check_id/feedbacks" do
  let(:quote_check) { create(:quote_check, :invalid) }
  let(:validation_error_details_id) { quote_check.validation_error_details.first.fetch("id") }
  let(:quote_check_id) { quote_check.id }

  let(:json) { response.parsed_body }

  describe "POST /api/v1/quote_checks/:quote_check_id/feedbacks" do
    let(:quote_check_feedback_params) do
      {
        validation_error_details_id: validation_error_details_id,
        is_helpful: false,
        comment: "FAUX"
      }
    end

    it "returns a successful response" do
      post api_v1_quote_check_feedbacks_url(quote_check_id: quote_check_id), params: quote_check_feedback_params,
                                                                             headers: basic_auth_header
      Rails.root.join("error.html").write(response.body) # @@@
      expect(response).to be_successful
    end

    it "returns a created response" do
      post api_v1_quote_check_feedbacks_url(quote_check_id: quote_check_id), params: quote_check_feedback_params,
                                                                             headers: basic_auth_header
      expect(response).to have_http_status(:created)
    end

    it "returns the QuoteCheckFeedback" do
      post api_v1_quote_check_feedbacks_url(quote_check_id: quote_check_id), params: quote_check_feedback_params,
                                                                             headers: basic_auth_header
      expect(json.fetch("quote_check_id")).to eq(quote_check_id)
    end

    it "creates a QuoteCheckFeedback" do
      expect do
        post api_v1_quote_check_feedbacks_url(quote_check_id: quote_check_id), params: quote_check_feedback_params,
                                                                               headers: basic_auth_header
      end.to change(QuoteCheckFeedback, :count).by(1)
    end

    context "with wrong error details id" do
      it "returns a unprocessable entity response" do
        post api_v1_quote_check_feedbacks_url(quote_check_id: quote_check_id),
             params: quote_check_feedback_params.merge(validation_error_details_id: "wrong"),
             headers: basic_auth_header
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
