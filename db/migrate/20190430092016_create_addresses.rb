# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.belongs_to :user, optional: true
      t.belongs_to :client, optional: true
      t.string :label
      t.string :street_number
      t.string :unit_number
      t.string :street_name
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
