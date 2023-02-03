class AddHasDisabilityToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :has_disability, :boolean
  end
end
