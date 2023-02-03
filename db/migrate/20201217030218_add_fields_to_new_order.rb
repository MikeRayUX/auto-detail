class AddFieldsToNewOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :address, :string
    add_column :new_orders, :unit_number, :string
    add_column :new_orders, :directions, :string
    add_column :new_orders, :accept_by, :datetime
  end
end
