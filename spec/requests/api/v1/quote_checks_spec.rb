# frozen_string_literal: true

# spec/controllers/posts_controller_spec.rb
require "rails_helper"

RSpec.describe "/api/v1/quote_checks" do
  describe "POST /api/v1/quote_checks" do
    let(:file) { fixture_file_upload("quote_files/Devis_test.pdf") }
    let(:quote_check_params) do
      {
        file: file,
        profile: "artisan"
      }
    end
    let(:json) { response.parsed_body }

    it "returns a successful response" do
      post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
      expect(response).to be_successful
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "returns a complete response" do
      post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
      expect(json.fetch("status")).to eq("invalid")
      expect(json.fetch("validation_errors")).to include("devis_manquant")
    end
    # rubocop:enable RSpec/MultipleExpectations

    it "creates a QuoteCheck" do
      expect do
        post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
      end.to change(QuoteCheck, :count).by(1)
    end

    context "with invalid file type" do
      let(:file) { fixture_file_upload("quote_files/Devis_test.png") }

      # rubocop:disable RSpec/MultipleExpectations
      it "returns a direct error response" do
        post api_v1_quote_checks_url, params: { quote_check: quote_check_params }
        expect(json.fetch("status")).to eq("invalid")
        expect(json.fetch("validation_errors")).to include("unsupported_file_format")
      end
      # rubocop:enable RSpec/MultipleExpectations
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
