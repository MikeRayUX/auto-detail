class AddStripeTaxRateIdToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :stripe_tax_rate_id, :string
  end
end
