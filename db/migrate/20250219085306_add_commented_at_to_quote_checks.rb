# frozen_string_literal: true

class AddCommentedAtToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :commented_at, :datetime
  end
end
