class AddClientIdToAddressAndOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :client_id, :bigint
    add_column :orders, :client_id, :bigint

    add_index :addresses, :client_id
    add_index :orders, :client_id
  end
end
