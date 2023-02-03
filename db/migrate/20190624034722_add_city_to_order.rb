# frozen_string_literal: true

class AddCityToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :city, :string
  end
end
