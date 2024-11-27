# frozen_string_literal: true

class CreateQuoteChecks < ActiveRecord::Migration[7.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :quote_checks, id: :uuid do |t|
      t.references :file, null: true, foreign_key: { to_table: :quote_files }, type: :uuid

      t.datetime :started_at, null: false
      t.datetime :finished_at
      t.string :profile, null: false

      t.text :text
      t.text :anonymised_text
      t.jsonb :naive_attributes
      t.string :naive_version
      t.jsonb :qa_attributes
      t.string :qa_version
      t.jsonb :read_attributes

      t.jsonb :validation_errors
      t.string :validation_version

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
