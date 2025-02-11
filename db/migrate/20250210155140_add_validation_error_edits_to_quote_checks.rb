# frozen_string_literal: true

class AddValidationErrorEditsToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :validation_error_edits, :jsonb
  end
end
