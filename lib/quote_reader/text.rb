# frozen_string_literal: true

require "pdf-reader"

module QuoteReader
  # Read Quote text to extract Quote attributes
  class Text
    attr_reader :text

    def initialize(text)
      @text = text
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read_attributes
      {
        devis: text[/devis/i],
        numero_devis: find_numero_devis(text),

        client: {
          nom: text[/Nom\s*:\s*(\w+)/i, 1],
          prenom: text[/Prénom\s*:\s*(\w+)/i, 1],
          adresse: text[/Adresse\s*:\s*(\w+)/i, 1],
          adresse_chantier: text[/Adresse chantier\s*:\s*(\w+)/i, 1]
        },
        pro: {
          adresse: text[/Adresse Pro\s*:\s*(\w+)/i, 1],
          raison_sociale: text[/Raison sociale\s*:\s*(\w+)/i, 1],
          forme_juridique: text[/Forme juridique\s*:\s*(\w+)/i, 1],
          numero_tva: text[/TVA\s*:\s*(\w+)/i, 1],
          capital: text[/Capital\s*:\s*(\w+)/i, 1],
          siret: find_siret(text),

          rge_number: find_rge_number(text)
        },

        full_text: text
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def find_numero_devis(text)
      text[/DEVIS\s+N°\s*(\d+)/i, 1] if text
    end

    def find_rge_number(text)
      text[/RGE\s+N°\s*(\d+)/i, 1] if text
    end

    def find_siret(text)
      text[/SIRET\s*:\s*(\d{3}\s*\d{3}\s*\d{3}\s*\d{5})/i, 1]&.gsub(/\s/, "") if text
    end
  end
end
