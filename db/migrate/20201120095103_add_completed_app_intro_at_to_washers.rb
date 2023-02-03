class AddCompletedAppIntroAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :completed_app_intro_at, :datetime
  end
end
