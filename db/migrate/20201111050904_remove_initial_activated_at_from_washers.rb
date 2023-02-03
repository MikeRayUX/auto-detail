class RemoveInitialActivatedAtFromWashers < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :initial_activated_at
  end
end
