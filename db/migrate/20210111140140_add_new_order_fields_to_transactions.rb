class AddNewOrderFieldsToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :new_order_id, :string
    add_column :transactions, :new_order_reference_code, :string
    add_column :transactions, :stripe_subscription_id, :string
  end
end
