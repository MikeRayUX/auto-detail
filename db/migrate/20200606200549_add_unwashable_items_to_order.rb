class AddUnwashableItemsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :unwashable_items, :boolean, default: false
  end
end
