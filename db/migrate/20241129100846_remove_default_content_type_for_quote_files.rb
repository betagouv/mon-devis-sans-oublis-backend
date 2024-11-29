# frozen_string_literal: true

class RemoveDefaultContentTypeForQuoteFiles < ActiveRecord::Migration[7.2]
  def change
    change_column_default :quote_files, :content_type, from: "unknown", to: nil
  end
end
