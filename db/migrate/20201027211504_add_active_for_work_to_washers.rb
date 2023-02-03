class AddActiveForWorkToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :active_for_work, :boolean, default: false
  end
end
