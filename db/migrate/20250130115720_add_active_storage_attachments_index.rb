# frozen_string_literal: true

class AddActiveStorageAttachmentsIndex < ActiveRecord::Migration[7.2]
  def change
    change_column_null :active_storage_attachments, :record_id, false

    add_index :active_storage_attachments, %w[record_type record_id name blob_id],
              name: "index_active_storage_attachments_uniqueness", unique: true
  end
end
