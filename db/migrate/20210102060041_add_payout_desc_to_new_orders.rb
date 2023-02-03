class AddPayoutDescToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :payout_desc, :string
  end
end
