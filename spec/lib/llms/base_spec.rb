# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llms::Base, type: :service do
  describe "extract_numbered_list" do
    it "returns a list of numbered items" do # rubocop:disable RSpec/ExampleLength
      numbered_list = described_class.extract_numbered_list(
        <<~TEXT
          # Voici les informations extraites du texte :

          1. **noms** : Dupont Franck

          2. **rien** :

          3. **adresses** : 5 rue de l'union, 06300 NICE / 8 Rue du Vinaigrier, 94300 Vincennes
        TEXT
      )

      expect(numbered_list.dig(2, :value)).to eq([
                                                   "5 rue de l'union, 06300 NICE",
                                                   "8 Rue du Vinaigrier, 94300 Vincennes"
                                                 ])
    end
  end
end
