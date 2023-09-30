class RemoveAttrEncryptedCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    remove_column :calendar_events, :encrypted_uuid
    remove_column :calendar_events, :encrypted_uuid_iv
  end
end
