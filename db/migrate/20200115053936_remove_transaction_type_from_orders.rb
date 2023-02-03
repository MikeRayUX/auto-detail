class RemoveTransactionTypeFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :transaction_type
  end
end
