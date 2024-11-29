# frozen_string_literal: true

class AddContentTypeToQuoteFiles < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_files, :content_type, :string, null: false, default: "unknown"
  end
end
