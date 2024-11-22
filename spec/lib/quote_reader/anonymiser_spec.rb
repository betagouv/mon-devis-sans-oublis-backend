# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteReader::Anonymiser, type: :service do
  describe "#anonymised_text" do
    it "anonymises the text" do
      expect(described_class.new("Devis\nNumero de devis : 1234\n\nClient\nNom : Doe\nPrenom : John").anonymised_text)
        .to eq("Devis\nNumero de devis : 1234\n\nClient\nNom : NOM\nPrenom : John")
    end
  end
end
