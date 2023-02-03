class AddIndexToOrdersReferenceCode < ActiveRecord::Migration[5.2]
  def change
    add_index :orders, :reference_code
  end
end
