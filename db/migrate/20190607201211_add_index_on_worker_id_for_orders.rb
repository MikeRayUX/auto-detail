# frozen_string_literal: true

class AddIndexOnWorkerIdForOrders < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :worker_id
  end
end
