# frozen_string_literal: true

class AddCourierDeliveredLocationToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :courier_stated_delivered_location, :string
  end
end
