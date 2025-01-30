# frozen_string_literal: true

class RemoveQuoteFileUniqueIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :quote_files, %i[hexdigest filename], unique: true
  end
end
