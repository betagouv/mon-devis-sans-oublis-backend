# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteCheckSerializer, type: :serializer do
  let(:serialized_quote_check) { described_class.new(quote_check).as_json }

  describe "serialization" do
    context "when check timeout" do
      let(:quote_check) { create(:quote_check, started_at: 2.hours.ago) }

      it "add the timeout error" do # rubocop:disable RSpec/MultipleExpectations
        expect(serialized_quote_check).to include(status: "invalid")
        expect(serialized_quote_check.dig(:error_details, 0)).to include(
          "code" => "server_timeout_error",
          "category" => "server"
        )
      end
    end
  end
end
