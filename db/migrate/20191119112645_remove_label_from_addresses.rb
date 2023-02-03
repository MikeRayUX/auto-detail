class RemoveLabelFromAddresses < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :label
  end
end
