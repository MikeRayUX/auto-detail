# frozen_string_literal: true

class MoveBagcountAndBaglistFromStopsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :bag_codes, :string
    add_column :orders, :bags_collected, :integer
  end
end
