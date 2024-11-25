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
          TVA : FR12345678911
          Capital : 1000 €
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
            adresse: "42",
            raison_sociale: "ACME",
            forme_juridique: "SAS",
            numero_tva: "FR12345678911",
            capital: "1000",
            rge_number: nil,
            siret: nil
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end

  # rubocop:disable RSpec/MultipleExpectations

  describe ".find_adresse" do
    it "returns the adresse" do
      skip "Add test for find_adresse"
    end
  end

  describe ".find_adresse_chantier" do
    it "returns the adresse_chantier" do
      skip "Add test for find_adresse_chantier"
    end
  end

  describe ".find_adresse_pro" do
    it "returns the adresse_pro" do
      skip "Add test for find_adresse_pro"
    end
  end

  describe ".find_assurance" do
    it "returns the assurance" do
      expect(
        described_class.find_assurance("Assurance décennale : ToutRix couverture France n° contrat 0000010001234567")
      ).to eq("ToutRix couverture France n° contrat 0000010001234567")
    end
  end

  describe ".find_capital" do
    it "returns the capital" do
      expect(described_class.find_capital("capital de 12345 €")).to eq("12345")
      expect(described_class.find_capital("capilâide 12 345€")).to eq("12 345")
    end
  end

  describe ".find_iban" do
    it "returns the iban" do
      expect(
        described_class.find_iban("IBAN : FR74 3000 1234 9000 0000 1234 P77")
      ).to eq("FR74 3000 1234 9000 0000 1234 P77")
    end
  end

  describe ".find_forme_juridique" do
    it "returns the forme_juridique" do
      skip "Add test for find_forme_juridique"
    end
  end

  describe ".find_mention_devis" do
    it "returns the mention_devis" do
      skip "Add test for find_mention_devis"
    end
  end

  describe ".find_nom" do
    it "returns the nom" do
      skip "Add test for find_nom"
    end
  end

  describe ".find_numero_devis" do
    it "returns the numero_devis" do
      expect(described_class.find_numero_devis("Devis  N\"   ORG201234")).to eq("ORG201234")
      expect(described_class.find_numero_devis("Devis n° DC001234")).to eq("DC001234")
    end
  end

  describe ".find_numero_tva" do
    it "returns the numero_tva" do
      expect(described_class.find_numero_tva("TVA  :FR10831861234")).to eq("FR10831861234")
      expect(described_class.find_numero_tva("TVA intracommunautaire : FR86504321234")).to eq("FR86504321234")
    end
  end

  describe ".find_prenom" do
    it "returns the prenom" do
      skip "Add test for find_prenom"
    end
  end

  describe ".find_raison_sociale" do
    it "returns the raison_sociale" do
      skip "Add test for find_raison_sociale"
    end
  end

  describe ".find_rge_number" do
    it "returns the rge_number" do
      expect(described_class.find_rge_number("RGE  n. :E123456")).to eq("E123456")
      expect(described_class.find_rge_number("RGE n°E-E123456")).to eq("E-E123456")
    end
  end

  describe ".find_siret" do
    it "returns the siret" do
      expect(described_class.find_siret("Siret : 12345678900000")).to eq("12345678900000")
      expect(described_class.find_siret("Siret : 123 456 789 00000")).to eq("123 456 789 00000")
    end
  end

  describe ".find_telephone" do
    it "returns the telephone" do
      expect(described_class.find_telephone(" (33) 01 23 45 67 89")).to eq("(33) 01 23 45 67 89")
    end
  end

  # rubocop:enable RSpec/MultipleExpectations
end
