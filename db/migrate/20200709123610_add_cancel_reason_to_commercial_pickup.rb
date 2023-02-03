class AddCancelReasonToCommercialPickup < ActiveRecord::Migration[5.2]
  def change
    add_column :commercial_pickups, :problem_encountered, :integer

    add_column :commercial_pickups, :courier_stated_delivered_location, :integer
  end
end
