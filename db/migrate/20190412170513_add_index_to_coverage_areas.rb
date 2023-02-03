# frozen_string_literal: true

class AddIndexToCoverageAreas < ActiveRecord::Migration[5.2]
  def change
    add_index :coverage_areas, :zipcode, unique: true
  end
end
