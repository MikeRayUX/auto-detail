class AddRegionNameAndTaxRateToTransactions < ActiveRecord::Migration[5.2]
	def change
		add_column :transactions, :region_name, :string
		add_column :transactions, :tax_rate, :float
  end
end
