class AddApplicationQuestionaireAttributesToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :live_within_region, :boolean
    add_column :washers, :min_age, :boolean
    add_column :washers, :legal_to_work, :boolean
    add_column :washers, :valid_drivers_license, :boolean
    add_column :washers, :valid_car_insurance_coverage, :boolean
    add_column :washers, :valid_ssn, :boolean
    add_column :washers, :reliable_transportation, :boolean
    add_column :washers, :can_lift_30_lbs, :boolean
  end
end
