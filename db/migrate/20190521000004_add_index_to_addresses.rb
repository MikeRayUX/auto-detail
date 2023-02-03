# frozen_string_literal: true

class AddIndexToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_index :addresses, :worker_id
  end
end
