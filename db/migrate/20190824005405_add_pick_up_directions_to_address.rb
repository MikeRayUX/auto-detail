# frozen_string_literal: true

class AddPickUpDirectionsToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :pick_up_directions, :string
  end
end
