class AddFailedPickupFeeToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :failed_pickup_fee, :decimal, precision: 12, scale: 2
  end
end
