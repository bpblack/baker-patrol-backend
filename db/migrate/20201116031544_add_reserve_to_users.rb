class AddReserveToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :reserve, :boolean, default: false
  end
end
