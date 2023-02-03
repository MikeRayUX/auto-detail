class AddBackgroundCheckApprovedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :background_check_approved_at, :datetime
  end
end
