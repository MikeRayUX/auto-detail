class AddPoundsToTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :retries

    add_column :transactions, :weight, :decimal, precision: 12, scale: 2

    add_column :transactions, :price_per_pound, :decimal, precision: 12, scale: 2
  end
end
