# frozen_string_literal: true

module QuoteReader
  # Anonymise Quote text
  class Anonymiser
    def initialize(raw_text)
      @raw_text = raw_text
    end

    # rubocop:disable Layout/CommentIndentation
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def anonymised_text
      return nil if @raw_text.nil?

        # TODO: Make it more generic
      attributes = QuoteReader::NaiveText.new(@raw_text).read

      tmp_anonymised_text = @raw_text

        # client

      nom = attributes.dig(:client, :nom)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{nom}/i, ("NOM" * 10)[0...nom.size]) if nom

      prenom = attributes.dig(:client, :prenom)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{prenom}/i, ("PRENOM" * 10)[0...prenom.size]) if prenom

      addresse = attributes.dig(:client, :addresse)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{addresse}/i, ("ADRESSE" * 10)[0...addresse.size]) if addresse

      adresse_chantier = attributes.dig(:client, :adresse_chantier)
      if adresse_chantier
        tmp_anonymised_text = tmp_anonymised_text.gsub(/#{adresse_chantier}/i,
                                                       ("ADRESSE CHANTIER" * 10)[0...adresse_chantier.size])
      end

        # pro

      adresse = attributes.dig(:client, :adresse)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{adresse}/i, ("ADRESSE" * 10)[0...adresse.size]) if adresse

      raison_sociale = attributes.dig(:client, :raison_sociale)
      if raison_sociale
        tmp_anonymised_text = tmp_anonymised_text.gsub(/#{raison_sociale}/i,
                                                       ("RAISON SOCIALE" * 10)[0...raison_sociale.size])
      end

      forme_juridique = attributes.dig(:client, :forme_juridique)
      if forme_juridique
        tmp_anonymised_text = tmp_anonymised_text.gsub(/#{forme_juridique}/i,
                                                       ("forme juridique" * 10)[0...forme_juridique.size])
      end

      numero_tva = attributes.dig(:client, :numero_tva)
      if numero_tva
        tmp_anonymised_text = tmp_anonymised_text.gsub(/#{numero_tva}/i,
                                                       ("numero_tva" * 10)[0...numero_tva.size])
      end

      capital = attributes.dig(:client, :capital)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{capital}/i, ("capital" * 10)[0...capital.size]) if capital

      siret = attributes.dig(:client, :siret)
      tmp_anonymised_text = tmp_anonymised_text.gsub(/#{siret}/i, ("siret" * 10)[0...siret.size]) if siret

      rge_number = attributes.dig(:client, :rge_number)
      if rge_number
        tmp_anonymised_text = tmp_anonymised_text.gsub(/#{rge_number}/i,
                                                       ("rge_number" * 10)[0...rge_number.size])
      end

      tmp_anonymised_text
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Layout/CommentIndentation
  end
end
