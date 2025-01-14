# frozen_string_literal: true

class AddMetadataToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :metadata, :jsonb
  end
end
