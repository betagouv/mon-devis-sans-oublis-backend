# frozen_string_literal: true

class ReaddQuoteFileUniqueIndex < ActiveRecord::Migration[7.2]
  def change
    add_index :quote_files, %i[hexdigest filename], unique: true
  end
end
