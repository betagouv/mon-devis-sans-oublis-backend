# frozen_string_literal: true

# attributes = { sirets: ['50432740400035'] }; ExtendedData.new(attributes).extended_attributes
# Add data from other sources
class ExtendedData
  attr_accessor :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  def extended_attributes
    data_from_sirets(sirets)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def data_from_sirets(sirets)
    results = sirets.flat_map do |siret|
      DataAdeme.new.historique_rge(qs: "siret:#{siret}").fetch("results")
    end

    {
      extended_data: {
        from_sirets: results
      },

      adresses: results.map { "#{it['adresse']}, #{it['code_postal']} #{it['commune']}" }.uniq,
      emails: results.pluck("email").uniq,
      labels: results.pluck("code_qualification").uniq,
      noms: results.pluck("nom_entreprise").uniq,
      telephones: results.pluck("telephone").uniq,
      uris: results.pluck("site_internet").uniq
    }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def sirets
    return [] unless attributes.key?(:sirets)

    attributes[:sirets].map { it.strip.gsub(/[^\d]/, "") }
                       .group_by { it }
                       .sort_by { |_, group| -group.size }
                       .map(&:first)
  end
end
