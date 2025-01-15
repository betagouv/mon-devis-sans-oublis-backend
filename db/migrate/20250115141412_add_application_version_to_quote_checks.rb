# frozen_string_literal: true

class AddApplicationVersionToQuoteChecks < ActiveRecord::Migration[7.2]
  def change
    add_column :quote_checks, :application_version, :string
  end
end
