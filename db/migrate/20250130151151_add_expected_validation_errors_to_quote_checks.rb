# frozen_string_literal: true

class AddExpectedValidationErrorsToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :expected_validation_errors, :jsonb
  end
end
