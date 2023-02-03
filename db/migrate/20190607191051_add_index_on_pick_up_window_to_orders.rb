# frozen_string_literal: true

class AddIndexOnPickUpWindowToOrders < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :pick_up_window
  end
end
