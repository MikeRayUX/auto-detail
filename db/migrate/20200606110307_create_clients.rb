class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :email
      t.string :special_notes
      t.string :contact_person
      t.string :area_of_business
      t.integer :pickup_frequency
      t.integer :pickup_day
      t.integer :pickup_window
      t.datetime :next_pickup
      t.integer :billing_frequency
      t.string :card_brand
      t.string :card_exp_month
      t.string :card_exp_year
      t.string :card_last4

      t.timestamps
    end
  end
end
