class AddRoleRefToPatrolResponsibility < ActiveRecord::Migration[5.0]
  def change
    add_reference :patrol_responsibilities, :role, foreign_key: true
  end
end
