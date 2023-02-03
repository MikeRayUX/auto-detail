# frozen_string_literal: true

class AddUnitNumberToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :unit_number, :string
  end
end
