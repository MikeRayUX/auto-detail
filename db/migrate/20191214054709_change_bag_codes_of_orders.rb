class ChangeBagCodesOfOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :orders, :bag_codes, :bags_code
  end
end
