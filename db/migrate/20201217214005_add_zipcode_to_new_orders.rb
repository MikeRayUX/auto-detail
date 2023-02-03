class AddZipcodeToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :zipcode, :string
  end
end
