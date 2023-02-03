# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.belongs_to :user
      t.string :pick_up_directions
      t.string :special_notes
      t.decimal :order_total, precision: 12, scale: 2
      t.decimal :weight, precision: 12, scale: 2
      t.datetime :picked_up_at
      t.datetime :dropped_off_at

      t.timestamps
    end
  end
end
