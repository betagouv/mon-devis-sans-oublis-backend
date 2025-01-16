# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llms::Base, type: :service do
  describe ".clean_value" do
    it "removes empty mentions" do # rubocop:disable RSpec/MultipleExpectations
      expect(described_class.clean_value(" Non mentionné ")).to be_nil
      expect(described_class.clean_value("Non disponible")).to be_nil
      expect(described_class.clean_value("Aucun IBAN n'est mentionné.")).to be_nil
      expect(described_class.clean_value("Inconnu (pas de nom de client)")).to be_nil
      expect(described_class.clean_value("Aucune")).to be_nil
    end
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
  end
end
