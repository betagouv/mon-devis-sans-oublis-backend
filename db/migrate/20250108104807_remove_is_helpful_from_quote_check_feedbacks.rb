# frozen_string_literal: true

class RemoveIsHelpfulFromQuoteCheckFeedbacks < ActiveRecord::Migration[7.2]
  def change
    remove_column :quote_check_feedbacks, :is_helpful, :boolean
  end
end
