class AddTosAcceptedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :tos_accepted_at, :datetime
  end
end
