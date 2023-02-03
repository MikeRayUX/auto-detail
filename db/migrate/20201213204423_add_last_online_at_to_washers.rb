class AddLastOnlineAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :last_online_at, :datetime
  end
end
