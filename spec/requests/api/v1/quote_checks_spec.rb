# frozen_string_literal: true

# spec/controllers/posts_controller_spec.rb
require "rails_helper"

RSpec.describe "/api/v1/quote_checks" do
  let(:json) { response.parsed_body }

  describe "POST /api/v1/quote_checks" do
    let(:file) { fixture_file_upload("quote_files/Devis_test.pdf") }
    let(:quote_check_params) do
      {
        file: file,
        profile: "artisan"
      }
    end

    it "returns a successful response" do
      post api_v1_quote_checks_url, params: quote_check_params, headers: basic_auth_header
      expect(response).to be_successful
    end

    it "returns a created response" do
      post api_v1_quote_checks_url, params: quote_check_params, headers: basic_auth_header
      expect(response).to have_http_status(:created)
    end

    it "returns a pending treatment response" do
      post api_v1_quote_checks_url, params: quote_check_params, headers: basic_auth_header
      expect(json.fetch("status")).to eq("pending")
    end

    it "creates a QuoteCheck" do
      expect do
        post api_v1_quote_checks_url, params: quote_check_params, headers: basic_auth_header
      end.to change(QuoteCheck, :count).by(1)
    end
  end

  describe "GET /api/v1/quote_checks/:id" do
    let(:quote_file) { create(:quote_file) }
    let(:quote_check) { create(:quote_check, file: quote_file) }

    before do
      QuoteCheckCheckJob.new.perform(quote_check.id)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "renders a successful response" do
      get api_v1_quote_check_url(quote_check), as: :json
      expect(response).to be_successful
      expect(json.fetch("status")).to eq("invalid")
    end
    # rubocop:enable RSpec/MultipleExpectations

    context "with invalid file type" do
      let(:file) { Rails.root.join("spec/fixtures/files/quote_files/Devis_test.png").open }
      let(:quote_file) { create(:quote_file, file: file) }

      # rubocop:disable RSpec/MultipleExpectations
      it "returns a direct error response" do
        get api_v1_quote_check_url(quote_check), as: :json
        expect(response).to be_successful
        expect(json.fetch("status")).to eq("invalid")
        expect(json.fetch("errors")).to include("file_reading_error")
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
