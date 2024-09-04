class AddIndexToCprStudents < ActiveRecord::Migration[7.2]
  def change
    add_index :cpr_students, :email_token
  end
end
