# frozen_string_literal: true

class CreateCoverageAreas < ActiveRecord::Migration[5.2]
  def change
    create_table :coverage_areas do |t|
      t.string :zipcode
      t.string :state
      t.string :county
      t.string :city

      t.timestamps
    end
  end
end
