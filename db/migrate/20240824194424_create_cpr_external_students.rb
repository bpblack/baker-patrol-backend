class CreateCprExternalStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :cpr_external_students do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: {unique: true}
      t.string :phone

      t.timestamps
    end

    add_index :cpr_external_students, [:first_name, :last_name], unique: true
  end
end
