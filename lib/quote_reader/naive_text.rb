# frozen_string_literal: true

module QuoteReader
  # Read Quote text to extract Quote attributes Naively
  # rubocop:disable Metrics/ClassLength
  class NaiveText < Text
    VERSION = "0.0.1"

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def read
      return {} if text.blank?

      @read_attributes = {
        devis: self.class.find_mention_devis(text),
        numero_devis: self.class.find_numero_devis(text),

        client: {
          nom: self.class.find_nom(text),
          prenom: self.class.find_nom(text),
          adresse_chantier: self.class.find_adresse_chantier(text)
        },
        pro: {
          adresse: self.class.find_adresse_pro(text),
          raison_sociale: self.class.find_raison_sociale(text),
          forme_juridique: self.class.find_forme_juridique(text),
          numero_tva: self.class.find_numeros_tva(text).first,
          capital: self.class.find_capital(text),
          siret: self.class.find_sirets(text).first,

          rge_number: self.class.find_rge_numbers(text).first,

          labels: self.class.find_label_numbers(text)
        },

        # Personal infos
        addresses: self.class.find_adresses(text),
        emails: self.class.find_emails(text),
        ibans: self.class.find_ibans(text),
        numeros_tva: self.class.find_numeros_tva(text),
        rcss: self.class.find_rcss(text),
        sirets: self.class.find_sirets(text),
        telephones: self.class.find_telephones(text),
        uris: self.class.find_uris(text)
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def version
      self.class::VERSION
    end

    NUMBER_REFERENCE_REGEX = /n?[.°]/i

    BETWEEN_LABEL_VALUE_REGEX = /\s+(?:#{NUMBER_REFERENCE_REGEX})?\s*(?::\s*)?/i
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    FORME_JURIDIQUE_REGEX = /SAS|S\.A\.S|S\.A\.S\.|SARL|S\.A\.R\.L|S\.A\.R\.L\.|EURL|E\.U\.R\.L|E\.U\.R\.L\./i
    FRENCH_ADDRESS_REGEX = /(?:\d{1,4}\s)?(?:[A-Za-zÀ-ÖØ-öø-ÿ'\-\s]+),?\s(?:\d{5})\s(?:[A-Za-zÀ-ÖØ-öø-ÿ'\-\s]+)/i
    FRENCH_CHARACTER_REGEX = /[\wÀ-ÖØ-öø-ÿ]/i
    PHONE_REGEX = /(?:\(?\+?33\)?)?\s?(?:[\s.]*\d\d){5}/i # TODO: find better
    RCS_REGEX = /R\.?C\.?S\.?(?:\s+[A-Za-zÀ-ÖØ-öø-ÿ\s-]+)?(?:\s+[AB])?\s+\d{9}/i
    URI_REGEX = %r{(?:https?|ftp)://[^\s/$.?#].[^\s]*}i

    def self.find_adresses(text)
      (text.scan(/Adresse\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i).flatten +
        text.scan(/(#{FRENCH_ADDRESS_REGEX})/i).flatten).uniq
    end

    def self.find_adresse_chantier(text)
      text[/Adresse chantier\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1] ||
        find_adresses(text).first
    end

    def self.find_adresse_pro(text)
      text[/Adresse Pro\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1] ||
        find_adresses(text).first
    end

    def self.find_assurance(text)
      text[/Assurance(?:\s+décennale)?#{BETWEEN_LABEL_VALUE_REGEX}((?:[#{FRENCH_CHARACTER_REGEX}:]+\s+)+(?:#{NUMBER_REFERENCE_REGEX}\s*)?(?:contrat\s+#{FRENCH_CHARACTER_REGEX}*\s*\d+)?)/i, 1] # rubocop:disable Layout/LineLength
    end

    def self.find_capital(text)
      text[/(?:Capitale?|capilâide)(?:\s+de)?#{BETWEEN_LABEL_VALUE_REGEX}(\d+(?: \d{3})*)\s*€/i, 1]
    end

    def self.find_emails(text)
      text.scan(/\b(#{EMAIL_REGEX})\b/i).flatten.compact.uniq
    end

    def self.find_forme_juridique(text)
      text[/\s+(#{FORME_JURIDIQUE_REGEX})\s+/, 1] ||
        text[/Forme juridique\s*:\s*(#{FRENCH_CHARACTER_REGEX}+) ?/i, 1]
    end

    def self.find_ibans(text)
      text.scan(
        /(?:IBAN|RIB)#{BETWEEN_LABEL_VALUE_REGEX}(FR\d{2}\s?(?:\d{4}\s?){2,5}#{FRENCH_CHARACTER_REGEX}?\d{2})/i
      ).flatten.compact.uniq
    end

    def self.find_label_numbers(text)
      # Warning : insure caracter before not match the IBAN
      text.scan(
        %r{(?:\A|.*#{BETWEEN_LABEL_VALUE_REGEX})((?:(?:CPLUS|QB|QPAC|QPV|QS|VPLUS)/|(?:R|E-)?E)\d{5,6})}i
      ).flatten.compact.uniq
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

    def self.find_numeros_tva(text)
      text.scan(/\bFR[A-Z0-9]{2}\d{9}\b/i).flatten.compact.uniq
    end

    def self.find_prenom(text)
      french_first_names = %w[Jean Marie Jacques Claire Pierre Sophie Amélie Luc Léa Élodie Chloé Théo]

      french_first_names.detect { |first_name| text[/(#{first_name})/i, 1] } ||
        text[/Prénom\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_raison_sociale(text)
      forme_jurique_raison_sociale_regex = /#{FORME_JURIDIQUE_REGEX}\s+.+|.+\s+#{FORME_JURIDIQUE_REGEX}/i

      text[/(#{forme_jurique_raison_sociale_regex})(?:\s+.*)?\Z/, 1] ||
        text[/\A(?:.*\s)?+(#{forme_jurique_raison_sociale_regex}\s+.+)\s+/, 1] ||
        text[/Raison sociale\s*:\s*(#{FRENCH_CHARACTER_REGEX}+)/i, 1]
    end

    def self.find_rge_numbers(text)
      find_label_numbers(text).select { |label_number| label_number.start_with?(/(?:R|E-)?E?/i) }
    end

    def self.find_sirets(text)
      text.scan(/\b(\d{3}\s*\d{3}\s*\d{3}\s*\d{5})\b/i).flatten.compact.uniq
    end

    def self.find_telephones(text)
      text.scan(/(?:T[eé]l\.?(?:[eé]phone)#{BETWEEN_LABEL_VALUE_REGEX})?(#{PHONE_REGEX})/i).flatten.compact.uniq
    end

    def self.find_rcss(text)
      text.scan(/\b(#{RCS_REGEX})\b/i).flatten.compact.uniq
    end

    def self.find_uris(text)
      text.scan(/\b(#{URI_REGEX})\b/i).flatten.compact.uniq
    end
  end
  # rubocop:enable Metrics/ClassLength
end
