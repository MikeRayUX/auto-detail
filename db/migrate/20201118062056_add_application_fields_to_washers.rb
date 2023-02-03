class AddApplicationFieldsToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :applied_at, :datetime
    add_column :washers, :authenticate_with_otp, :boolean, default: true
  end
end
