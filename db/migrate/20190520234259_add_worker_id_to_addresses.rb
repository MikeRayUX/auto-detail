# frozen_string_literal: true

class AddWorkerIdToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :worker_id, :integer
  end
end
