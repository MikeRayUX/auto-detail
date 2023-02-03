class AddMaxConcurrentOffersToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :max_concurrent_offers, :integer
  end
end
