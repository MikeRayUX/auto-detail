class RemoveFinalWeightFromTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :final_weight
  end
end
