# frozen_string_literal: true

class QuoteCheckSerializer < ActiveModel::Serializer
  attributes :id, :status, :profile, :metadata,
             :errors, :error_details, :error_messages,
             :parent_id,
             :filename,
             :gestes,
             :finished_at,
             # Virtual attributes
             :errors, :error_details, :error_messages,
             :gestes

  def attributes(*args)
    super.compact # Removes keys with nil values
  end

  def errors
    object.validation_errors
  end

  def error_details
    object.validation_error_details&.map do
      it.merge(
        "comment" => object.validation_error_edits&.dig(it["id"], "comment"),
        "deleted" => object.validation_error_edits&.dig(it["id"], "deleted") || false
      ).compact
    end
  end

  def error_messages
    object.validation_errors&.index_with do
      I18n.t("quote_validator.errors.#{it}")
    end
  end

  def gestes
    object.read_attributes&.fetch("gestes", nil)&.map&.with_index do |geste, geste_index| # rubocop:disable Style/SafeNavigationChainLength
      geste_id = QuoteValidator::Base.geste_index(object.id, geste_index)
      geste.slice("intitule").merge(
        "id" => geste_id,
        "valid" =>
          object.validation_error_details.none? do
            it["geste_id"] == geste_id
          end
      )
    end
  end
end
