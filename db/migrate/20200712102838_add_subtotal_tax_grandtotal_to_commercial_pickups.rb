class AddSubtotalTaxGrandtotalToCommercialPickups < ActiveRecord::Migration[5.2]
  def change
    add_column :commercial_pickups, :subtotal, :decimal, precision: 12, scale: 2
    add_column :commercial_pickups, :tax, :decimal, precision: 12, scale: 2
    add_column :commercial_pickups, :grandtotal, :decimal, precision: 12, scale: 2
    add_column :commercial_pickups, :tax_rate, :decimal, precision: 12, scale: 2
    add_column :commercial_pickups, :client_price_per_pound, :decimal, precision: 12, scale: 2
  end
end
