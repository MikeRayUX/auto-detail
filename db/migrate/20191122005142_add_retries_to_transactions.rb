class AddRetriesToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :retries, :integer, default: 0
  end
end
