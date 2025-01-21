# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llms::Base, type: :service do
  describe ".clean_value" do
    # rubocop:disable RSpec/ExampleLength
    it "removes empty mentions" do # rubocop:disable RSpec/MultipleExpectations
      expect(described_class.clean_value("**")).to be_nil
      expect(described_class.clean_value(" Non mentionné ")).to be_nil
      expect(described_class.clean_value("Non disponible")).to be_nil
      expect(described_class.clean_value("Aucun IBAN n'est mentionné.")).to be_nil
      expect(described_class.clean_value("Aucun IBAN mentionné.")).to be_nil
      expect(described_class.clean_value("Aucun label mentionné")).to be_nil
      expect(described_class.clean_value("Inconnu (pas de nom de client)")).to be_nil
      expect(described_class.clean_value("Aucune")).to be_nil
      expect(described_class.clean_value("aucune mention")).to be_nil
      expect(described_class.clean_value("aucune mention d'assurance")).to be_nil
      expect(described_class.clean_value("Aucune information trouvée")).to be_nil
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe ".extract_numbered_list" do
    context "when the text is made of one liners" do
      let(:text) do
        <<~TEXT
          # Voici les informations extraites du texte :

          1. **noms** : Dupont Franck

          2. **rien** :

          3. **adresses** : 5 rue de l'union, 06300 NICE / 8 Rue du Vinaigrier, 94300 Vincennes
        TEXT
      end

      it "returns a list of numbered items" do
        numbered_list = described_class.extract_numbered_list(text)

        expect(numbered_list.dig(2, :value)).to eq([
                                                     "5 rue de l'union, 06300 NICE",
                                                     "8 Rue du Vinaigrier, 94300 Vincennes"
                                                   ])
      end
    end

    context "when the text is made of multi liners" do
      let(:text) do
        <<~TEXT
          # Voici les informations extraites du texte :

          1. **noms** : Dupont Franck

          2. **rien** :

          3. **adresses** :#{' '}
           - 5 rue de l'union, 06300 NICE
           - 8 Rue du Vinaigrier, 94300 Vincennes
        TEXT
      end

      it "returns a list of numbered items" do
        numbered_list = described_class.extract_numbered_list(text)

        expect(numbered_list.dig(2, :value)).to eq([
                                                     "5 rue de l'union, 06300 NICE",
                                                     "8 Rue du Vinaigrier, 94300 Vincennes"
                                                   ])
      end
    end

    context "when the text is made of multi liners with a different separator" do
      let(:text) do
        <<~TEXT
          Voici les données demandées :

          **1. Noms** :#{' '}
          - DUPOND D

          **2. Adresses** :#{' '}
          - 4 montée de la barre, 12345 LAND

          **3. Forme juridiques** :#{' '}
          - EI (Entreprise Individuelle)",
                  "
        TEXT
      end

      it "returns a list of numbered items" do
        numbered_list = described_class.extract_numbered_list(text)
        expect(numbered_list.dig(1, :value)).to eq([
                                                     "4 montée de la barre, 12345 LAND"
                                                   ])
      end
    end
  end
end
