class AddHasCprCertToCprStudent < ActiveRecord::Migration[7.2]
  def change
    add_column :cpr_students, :has_cpr_cert, :boolean
  end
end
