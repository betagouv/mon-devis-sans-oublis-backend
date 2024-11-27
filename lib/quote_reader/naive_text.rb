# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes Naively
  class NaiveText < Text
    VERSION = "0.0.1"

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read
      return super if text.blank?

      @read_attributes = super.merge({
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

    def version
      self.class::VERSION
    end

    NUMBER_REFERENCE_REGEX = /n?[.°]/i
    BETWEEN_LABEL_VALUE_REGEX = /\s+(?:#{NUMBER_REFERENCE_REGEX})?\s*(?::\s*)?/i
    FRENCH_CHARACTER_REGEX = /[\wÀ-ÖØ-öø-ÿ]/i
    PHONE_REGEX = /(?:\(?\+?33\)?)?\s?(?:[\s.]*\d\d){5}/i # TODO: find better

    def self.find_adresse(text)
      text[/Adresse\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_adresse_chantier(text)
      text[/Adresse chantier\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_adresse_pro(text)
      text[/Adresse Pro\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_assurance(text)
      text[/Assurance(?:\s+décennale)?#{BETWEEN_LABEL_VALUE_REGEX}((?:[#{FRENCH_CHARACTER_REGEX}:]+\s+)+(?:#{NUMBER_REFERENCE_REGEX}\s*)?(?:contrat\s+#{FRENCH_CHARACTER_REGEX}*\s*\d+)?)/i, 1] # rubocop:disable Layout/LineLength
    end

    def self.find_capital(text)
      text[/(?:Capitale?|capilâide)(?:\s+de)?#{BETWEEN_LABEL_VALUE_REGEX}(\d+(?: \d{3})*)\s*€/i, 1]
    end

    def self.find_forme_juridique(text)
      text[/\s+(SAS|SARL|EURL)\s+/, 1] || text[/Forme juridique\s*:\s*(#{FRENCH_CHARACTER_REGEX}+) ?/i, 1]
    end

    def self.find_iban(text)
      text[/(?:IBAN|RIB)#{BETWEEN_LABEL_VALUE_REGEX}(FR\d{2}\s?(?:\d{4}\s?){2,5}#{FRENCH_CHARACTER_REGEX}?\d{2})/i, 1]
    end

    def self.find_mention_devis(text)
      text[/devis/i] if text
    end

    def self.find_nom(text)
      text[/Nom\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_numero_devis(text)
      text[/DEVIS\s+N.?\s*(#{FRENCH_CHARACTER_REGEX}*\d{4,})/i, 1]
    end

    def self.find_numero_tva(text)
      text[/(FR\d{2}\s?\d{9})/i, 1]
      # text[/TVA(?:\s+intra(?:communautaire)?)?#{BETWEEN_LABEL_VALUE_REGEX}(FR\d{2}\s?\d{9})/i, 1]
    end

    def self.find_prenom(text)
      text[/Prénom\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_raison_sociale(text)
      text[/Raison sociale\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_rge_number(text)
      text[/RGE#{BETWEEN_LABEL_VALUE_REGEX}((?:E-)?E?\d+)/i, 1]
    end

    def self.find_siret(text)
      text[/SIRET#{BETWEEN_LABEL_VALUE_REGEX}(\d{3}\s*\d{3}\s*\d{3}\s*\d{5})/i, 1]
    end

    def self.find_telephone(text)
      text[/(?:T[eé]l\.?(?:[eé]phone)#{BETWEEN_LABEL_VALUE_REGEX})?(#{PHONE_REGEX})/i, 1]
    end
  end
end
