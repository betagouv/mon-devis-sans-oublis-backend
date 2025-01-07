# frozen_string_literal: true

class AddPrivateDataQaToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    change_table :quote_checks, bulk: true do |t|
      t.jsonb :private_data_qa_attributes
      t.string :private_data_qa_version
      t.jsonb :private_data_qa_result
    end
  end
end
