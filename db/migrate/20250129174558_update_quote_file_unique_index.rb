# frozen_string_literal: true

class UpdateQuoteFileUniqueIndex < ActiveRecord::Migration[7.2]
  def change
    change_table :quote_files do |t|
      t.remove_index :hexdigest
      t.index %i[hexdigest filename], unique: true
    end
  end
end
