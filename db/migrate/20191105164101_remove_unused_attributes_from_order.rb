# frozen_string_literal: true

class RemoveUnusedAttributesFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :unit_number
  end
end
