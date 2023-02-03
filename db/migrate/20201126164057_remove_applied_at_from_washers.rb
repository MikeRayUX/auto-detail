class RemoveAppliedAtFromWashers < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :applied_at
  end
end
