class ChangeActiveForWorkOfWashers < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :active_for_work

    add_column :washers, :activated_at, :datetime
  end
end
