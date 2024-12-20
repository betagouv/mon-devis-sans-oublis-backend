# frozen_string_literal: true

class AddParentIdToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :parent_id, :uuid
    add_index :quote_checks, :parent_id
  end
end
