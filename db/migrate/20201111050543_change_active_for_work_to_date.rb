class ChangeActiveForWorkToDate < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :active_for_work

    add_column :washers, :active_for_work, :datetime
  end
end
