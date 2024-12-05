# frozen_string_literal: true

# spec/controllers/posts_controller_spec.rb
require "rails_helper"

RSpec.describe "/api/v1/quote_checks" do
  describe "POST /api/v1/quote_checks" do
    let(:quote_check_params) do
      {
        file: fixture_file_upload("quote_files/Devis_test.pdf"),
        profile: "artisan"
      }
    end

    it "returns a successful response" do
      post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
      expect(response).to be_successful
    end

    it "creates a QuoteCheck" do
      expect do
        post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
      end.to change(QuoteCheck, :count).by(1)
    end
  end

  describe "GET /api/v1/quote_checks/:id" do
    let(:quote_file) { create(:quote_file) }
    let(:quote_check) { create(:quote_check, file: quote_file) }

    it "renders a successful response" do
      get api_v1_quote_check_url(quote_check), as: :json
      expect(response).to be_successful
    end
  end
end
