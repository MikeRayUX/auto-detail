# frozen_string_literal: true

class AddWorkerIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :worker_id, :integer
  end
end
