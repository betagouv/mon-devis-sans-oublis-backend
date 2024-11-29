# frozen_string_literal: true

# This migration comes from active_storage_postgresql (originally 20180530020601)
class CreateActiveStoragePostgresqlTables < ActiveRecord::Migration[5.2]
  def change
    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :active_storage_postgresql_files do |t|
      t.oid :oid
      t.string :key

      t.index :key, unique: true
    end
    # rubocop:enable Rails/CreateTableWithTimestamps
  end
end
