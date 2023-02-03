class AddAttributesToWasher < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :phone, :string
  end
end
