class CreateCommercialPickups < ActiveRecord::Migration[5.2]
  def change
    create_table :commercial_pickups do |t|
      t.belongs_to :transaction
      t.belongs_to :client
      t.string :full_address
      t.string :routable_address
      t.string :reference_code
      t.string :pick_up_directions
      t.string :bags_code
      t.integer :pick_up_window
      t.integer :detergent
      t.integer :softener
      t.integer :global_status, default: 'created'
      t.integer :bags_collected
      t.datetime :pick_up_date
      t.datetime :picked_up_from_client_at
      t.datetime :dropped_off_to_partner_at
      t.datetime :picked_up_from_partner_at
      t.datetime :delivered_to_client_at
      t.decimal :weight, precision: 12, scale: 2
      t.boolean :paid, default: false

      t.timestamps
    end
    add_index :commercial_pickups, :reference_code
  end
end
