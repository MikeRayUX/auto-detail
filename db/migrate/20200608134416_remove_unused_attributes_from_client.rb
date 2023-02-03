class RemoveUnusedAttributesFromClient < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :pickup_frequency
    remove_column :clients, :billing_frequency
    remove_column :clients, :pickup_day
    remove_column :clients, :next_pickup

    add_column :clients, :price_per_pound, :decimal, precision: 12, scale: 2
    add_column :clients, :phone, :string
    add_column :clients, :stripe_customer_id, :string
    add_column :clients, :monday, :boolean, default: false
    add_column :clients, :tuesday, :boolean, default: false
    add_column :clients, :wednesday, :boolean, default: false
    add_column :clients, :thursday, :boolean, default: false
    add_column :clients, :friday, :boolean, default: false
    add_column :clients, :saturday, :boolean, default: false
    add_column :clients, :sunday, :boolean, default: false
    add_column :clients, :current_usage, :float, default: 0
  end
end
