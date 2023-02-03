class AddElibilityCompletedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :eligibility_completed_at, :datetime
  end
end
