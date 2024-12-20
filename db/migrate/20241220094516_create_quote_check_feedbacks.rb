# frozen_string_literal: true

class CreateQuoteCheckFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :quote_check_feedbacks, id: :uuid do |t|
      t.references :quote_check, type: :uuid, null: false, foreign_key: true

      t.string :validation_error_details_id
      t.boolean :is_helpful, null: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.text :comment

      t.timestamps
    end
  end
end
