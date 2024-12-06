# frozen_string_literal: true

class MakeDataOfQuoteFilesMandatory < ActiveRecord::Migration[7.2]
  def change
    change_column_null :quote_files, :data, false
  end
end
