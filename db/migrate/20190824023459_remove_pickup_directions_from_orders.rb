# frozen_string_literal: true

class RemovePickupDirectionsFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :pick_up_directions
  end
end
