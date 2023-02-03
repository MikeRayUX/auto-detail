class AddWashNotesToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :wash_notes, :string
  end
end
