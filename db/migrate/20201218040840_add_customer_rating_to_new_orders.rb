class AddCustomerRatingToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :customer_rating, :integer
  end
end
