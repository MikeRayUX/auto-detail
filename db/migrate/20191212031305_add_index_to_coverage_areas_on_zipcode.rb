class AddIndexToCoverageAreasOnZipcode < ActiveRecord::Migration[5.2]
  def change
    add_index :coverage_areas, :city
  end
end
