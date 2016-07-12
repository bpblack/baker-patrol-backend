class AddSubAcceptedToSubstitutions < ActiveRecord::Migration[5.0]
  def change
    add_column :substitutions, :sub_id, :integer
    add_column :substitutions, :accepted, :boolean, default: false
    add_index :substitutions, :sub_id
    add_foreign_key :substitutions, :users, column: :sub_id
  end
end
