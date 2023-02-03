class RemoveWashPreferences < ActiveRecord::Migration[5.2]
  def change
    drop_table :wash_preferences
  end
end
