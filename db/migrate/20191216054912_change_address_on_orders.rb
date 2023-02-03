class ChangeAddressOnOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :customer_address, :full_address
    
    add_column :orders, :routable_address, :string
    
    remove_column :orders, :city
  end
end
