class AddNoteToClassroom < ActiveRecord::Migration[8.0]
  def change
    add_column :classrooms, :note, :string
  end
end
