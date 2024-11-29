# frozen_string_literal: true

module QuoteReader
  # Anonymise Quote text
  class Anonymiser
    FIELDS_TO_ANONYMISE = [
      :adresses, :emails, :ibans, :numeros_tva, :rcss, :sirets, :telephones, :uris,
      { client: %i[adresse_chantier nom prenom] },
      { pro: %i[adresse capital forme_juridique labels numero_tva raison_sociale rge_number siret] }
    ].freeze

    def initialize(raw_text)
      @raw_text = raw_text
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # Recursive method to replace text from attributes, like Rails parameters
    def replace_text_from_attributes(attributes, fields_or_field, text)
      if fields_or_field.is_a?(Symbol)
        values = Array.wrap(attributes.fetch(fields_or_field))

        tmp_anonymised_text = text
        values.each do |value|
          tmp_anonymised_text = tmp_anonymised_text.gsub(
            /#{value}/i,
            (fields_or_field.to_s.singularize.upcase * 10)[0...value.size]
          )
        end
        return tmp_anonymised_text
      end

      if fields_or_field.is_a?(Array)
        tmp_anonymised_text = text
        fields_or_field.each do |field|
          tmp_anonymised_text = replace_text_from_attributes(attributes, field, tmp_anonymised_text)
        end
        return tmp_anonymised_text
      end

      if fields_or_field.is_a?(Hash)
        field = fields_or_field.keys.first
        return replace_text_from_attributes(attributes.fetch(field), fields_or_field.fetch(field), text)
      end

      raise NotImplementedError
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def anonymised_text
      return nil if @raw_text.nil?

      attributes = QuoteReader::NaiveText.new(@raw_text).read
      replace_text_from_attributes(attributes, FIELDS_TO_ANONYMISE, @raw_text)
    end
  end
end
