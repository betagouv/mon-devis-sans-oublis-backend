# frozen_string_literal: true

class AddQaResultToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :qa_result, :jsonb
  end
end
