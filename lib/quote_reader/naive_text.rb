# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes Naively
  class NaiveText < Text
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read_attributes
      return super if text.blank?

      super.merge({
                    devis: self.class.find_mention_devis(text),
                    numero_devis: self.class.find_numero_devis(text),

                    client: {
                      nom: self.class.find_nom(text),
                      prenom: self.class.find_nom(text),
                      adresse: self.class.find_adresse(text),
                      adresse_chantier: self.class.find_adresse_chantier(text)
                    },
                    pro: {
                      adresse: self.class.find_adresse_pro(text),
                      raison_sociale: self.class.find_raison_sociale(text),
                      forme_juridique: self.class.find_forme_juridique(text),
                      numero_tva: self.class.find_numero_tva(text),
                      capital: self.class.find_capital(text),
                      siret: self.class.find_siret(text),

                      rge_number: self.class.find_rge_number(text)
                    }
                  })
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def self.find_adresse_pro(text)
      text[/Adresse Pro\s*:\s*(\w+)/i, 1]
    end

    def self.find_raison_sociale(text)
      text[/Raison sociale\s*:\s*(\w+)/i, 1]
    end

    def self.find_forme_juridique(text)
      text[/Forme juridique\s*:\s*(\w+)/i, 1]
    end

    def self.find_numero_tva(text)
      text[/TVA\s*:\s*(\w+)/i, 1]
    end

    def self.find_capital(text)
      text[/Capital\s*:\s*(\w+)/i, 1]
    end

    def self.find_mention_devis(text)
      text[/devis/i] if text
    end

    def self.find_adresse(text)
      text[/Adresse\s*:\s*(\w+)/i, 1]
    end

    def self.find_adresse_chantier(text)
      text[/Adresse chantier\s*:\s*(\w+)/i, 1]
    end

    def self.find_nom(text)
      text[/Nom\s*:\s*(\w+)/i, 1]
    end

    def self.find_prenom(text)
      text[/Prénom\s*:\s*(\w+)/i, 1]
    end

    def self.find_numero_devis(text)
      text[/DEVIS\s+N°\s*(\d+)/i, 1]
    end

    def self.find_rge_number(text)
      text[/RGE\s+N°\s*(\d+)/i, 1]
    end

    def self.find_siret(text)
      text[/SIRET\s*:\s*(\d{3}\s*\d{3}\s*\d{3}\s*\d{5})/i, 1]&.gsub(/\s/, "")
    end
  end
end
