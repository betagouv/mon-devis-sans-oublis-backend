# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuoteReader::NaiveText, type: :service do
  describe "#read_attributes" do
    subject(:attributes) { described_class.new(text).read_attributes }

    context "when the text is nil" do
      let(:text) { nil }

      it { is_expected.to eq({ full_text: nil }) }
    end

    context "when the text is empty" do
      let(:text) { "" }

      it { is_expected.to eq({ full_text: "" }) }
    end

    context "when the text is not empty" do
      let(:text) do
        <<~TEXT
          Devis
          Numero de devis : 1234

          Client
          Nom : Doe
          Prenom : John
          Adresse : 42 rue du Paradis
          Adresse Chantier : 43 rue du Paradis

          Pro
          Adresse Pro : 42 rue
          Raison Sociale : ACME
          Forme Juridique : SAS
          TVA : 123456
          Capital : 1000
          Siret : 123456789
          RGE Number : 123456
        TEXT
      end

      # rubocop:disable RSpec/ExampleLength
      it "fills the attributes" do
        expect(attributes).to include(
          devis: "Devis",
          client: {
            nom: "Doe",
            prenom: "Doe",
            adresse: "42",
            adresse_chantier: "43"
          },
          pro: {
            adresse: "42 rue",
            raison_sociale: "ACME",
            forme_juridique: "SAS",
            numero_tva: "123456",
            capital: "1000"
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
