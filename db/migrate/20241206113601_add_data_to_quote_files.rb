# frozen_string_literal: true

class AddDataToQuoteFiles < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_files, :data, :binary
  end
end
