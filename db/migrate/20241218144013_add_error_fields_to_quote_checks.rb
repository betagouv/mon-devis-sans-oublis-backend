# frozen_string_literal: true

class AddErrorFieldsToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :validation_error_details, :jsonb
  end
end
