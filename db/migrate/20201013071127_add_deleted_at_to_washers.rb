class AddDeletedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :deleted_at, :datetime
  end
end
