# frozen_string_literal: true

class AddWindowToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pick_up_window, :string
  end
end
