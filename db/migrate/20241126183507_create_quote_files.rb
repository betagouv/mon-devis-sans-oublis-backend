# frozen_string_literal: true

class CreateQuoteFiles < ActiveRecord::Migration[7.2]
  def change
    create_table :quote_files, id: :uuid do |t|
      t.string :filename, null: false
      t.string :hexdigest, null: false, index: { unique: true }
      t.datetime :uploaded_at, null: false

      t.timestamps
    end
  end
end
