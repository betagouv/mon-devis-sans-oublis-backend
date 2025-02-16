# frozen_string_literal: true

class QuoteCheckSerializer < ActiveModel::Serializer
  # attributes :id, :status, :created_at # TODO

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def as_json(*args)
    json_hash = super.merge(object.attributes.merge({ # Warning: attributes has stringifed keys, so use it too
                                                      "status" => object.status,
                                                      "errors" => object.validation_errors,
                                                      "error_details" => object.validation_error_details&.map do
                                                        it.merge(
                                                          "comment" => object.validation_error_edits&.fetch(
                                                            it["id"], {}
                                                          )&.[]("comment") || nil,
                                                          "deleted" =>
                                                           object.validation_error_edits&.fetch(
                                                             it["id"], {}
                                                           )&.[]("deleted") || false
                                                        )
                                                      end,
                                                      "error_messages" => object.validation_errors&.index_with do
                                                        I18n.t("quote_validator.errors.#{it}")
                                                      end,
                                                      "filename" => object.filename,

                                                      "gestes" => object.read_attributes&.fetch("gestes", nil) # rubocop:disable Style/SafeNavigationChainLength
                     &.map&.with_index do |geste, geste_index|
                       geste_id = QuoteValidator::Base.geste_index(
                         object.id, geste_index
                       )

                       geste.slice("intitule").merge(
                         "id" => geste_id,
                         "valid" =>
                           object.validation_error_details.none? do
                             it["geste_id"] == geste_id
                           end
                       )
                     end
                                                    }))
    return json_hash if Rails.env.development?

    json_hash.slice(
      "id", "status", "profile", "metadata",
      "valid", "errors", "error_details", "error_messages",
      "parent_id",
      "filename",
      "gestes",
      "finished_at"
    ).compact
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
end
