class AddStripeTransferErrorToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :stripe_transfer_error, :string
  end
end
