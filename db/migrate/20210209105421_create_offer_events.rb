class CreateOfferEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :offer_events do |t|
      t.belongs_to :washer
      t.belongs_to :new_order
      t.integer :event_type
      t.string :feedback

      t.timestamps
    end
  end
end
