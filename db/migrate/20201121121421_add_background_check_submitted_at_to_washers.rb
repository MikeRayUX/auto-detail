class AddBackgroundCheckSubmittedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :background_check_submitted_at, :datetime
  end
end
