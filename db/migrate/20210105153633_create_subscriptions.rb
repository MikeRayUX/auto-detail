class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_product_id
      t.string :stripe_price_id
      t.decimal :price, precision: 12, scale: 2
      t.string :name

      t.timestamps
    end
  end
end
