class AddStripeRefundIdToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :stripe_refund_id, :string
  end
end
