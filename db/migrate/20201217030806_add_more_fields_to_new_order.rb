class AddMoreFieldsToNewOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :accepted_at, :datetime
    add_column :new_orders, :cancelled_at, :datetime
    add_column :new_orders, :completed_at, :datetime
  end
end
