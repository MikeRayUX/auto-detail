class AddWasherIdToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :washer_id, :bigint

    add_index :addresses, :washer_id
  end
end
