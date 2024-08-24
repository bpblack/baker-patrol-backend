class CreateCprStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :cpr_students do |t|
      t.references :cpr_class, null: false, foreign_key: true
      t.boolean :email_sent
      t.string :email_token
      t.references :cpr_year, null: false, foreign_key: true
      t.references :student, polymorphic: true, null: false

      t.timestamps
    end
    
    add_index :cpr_students, [:student_type, :student_id, :cpr_year_id], unique: true
  end
end
