class AddStripeChargeIdToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :stripe_charge_id, :string
  end
end
