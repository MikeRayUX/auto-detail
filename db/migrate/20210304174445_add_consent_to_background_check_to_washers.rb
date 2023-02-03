class AddConsentToBackgroundCheckToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :consent_to_background_check, :boolean
  end
end
