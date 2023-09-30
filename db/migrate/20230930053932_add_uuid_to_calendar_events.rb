class AddUuidToCalendarEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_events, :uuid, :string
  end
end
