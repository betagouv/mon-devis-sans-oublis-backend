# frozen_string_literal: true

class AddCommentsToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :comment, :text
  end
end
