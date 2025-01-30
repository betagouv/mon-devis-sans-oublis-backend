# frozen_string_literal: true

class FixActiveStorageAttachementsRecordId < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/BulkChangeTable
  def up
    remove_index :active_storage_attachments, name: "index_active_storage_attachments_uniqueness"
    remove_column :active_storage_attachments, :record_id

    add_column :active_storage_attachments, :record_id, :uuid
  end

  def down
    remove_column :active_storage_attachments, :record_id, :uuid

    add_column :active_storage_attachments, :record_id, :bigint
    add_index :active_storage_attachments, %w[record_type record_id name blob_id],
              name: "index_active_storage_attachments_uniqueness", unique: true
  end
  # rubocop:enable Rails/BulkChangeTable
end
