# frozen_string_literal: true

class AddPickUpDateToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pick_up_date, :datetime
  end
end
