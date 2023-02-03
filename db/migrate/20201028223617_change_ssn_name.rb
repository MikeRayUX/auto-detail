class ChangeSsnName < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :secure_ssn
    add_column :washers, :ssn, :string
  end
end
