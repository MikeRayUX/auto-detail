# frozen_string_literal: true

class RemoveCityFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :city
  end
end
