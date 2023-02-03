class AddPricingRelationshipToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :region_pricing_id, :integer

    add_index :orders, :region_pricing_id
  end
end
