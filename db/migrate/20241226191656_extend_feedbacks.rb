# frozen_string_literal: true

class ExtendFeedbacks < ActiveRecord::Migration[7.2]
  def change
    change_table :quote_check_feedbacks, bulk: true do |t|
      t.string :email
      t.integer :rating
    end

    change_column_null :quote_check_feedbacks, :is_helpful, true
  end
end
