# frozen_string_literal: true

class AddIndexToOrdersStatus < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :status
  end
end
