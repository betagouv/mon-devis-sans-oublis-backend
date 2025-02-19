# frozen_string_literal: true

class AddValidationErrorEditedAttToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :validation_error_edited_at, :datetime
  end
end
