# frozen_string_literal: true

class RemoveWorkerIdFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :worker_id
  end
end
