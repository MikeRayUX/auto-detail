class AddStripeTransferIdToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :stripe_transfer_id, :string
  end
end
