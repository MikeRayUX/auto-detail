class AddFieldsToWasher < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :first_name, :string
    add_column :washers, :middle_name, :string
    add_column :washers, :last_name, :string
    add_column :washers, :date_of_birth, :string
  end
end
