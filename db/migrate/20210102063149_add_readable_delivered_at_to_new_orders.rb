class AddReadableDeliveredAtToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :readable_delivered_at, :string
  end
end
