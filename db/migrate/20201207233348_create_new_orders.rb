class CreateNewOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :new_orders do |t|
      t.belongs_to :user
      t.belongs_to :washer
      t.belongs_to :region
      t.string :ref_code
      t.integer :detergent
      t.integer :softener
      t.integer :bag_count
      t.datetime :scheduled
      t.datetime :picked_up_at
      t.datetime :delivered_at
      t.datetime :est_delivery
      t.integer :status
      t.integer :delivery_location
      t.integer :bag_price
      t.float :tax_rate
      t.decimal :subtotal, precision: 12, scale: 2
      t.decimal :tax, precision: 12, scale: 2
      t.decimal :grandtotal, precision: 12, scale: 2
      t.decimal :tip, precision: 12, scale: 2
      t.timestamps
    end
  end
end
