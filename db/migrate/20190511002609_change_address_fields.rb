# frozen_string_literal: true

class ChangeAddressFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :street_number
    remove_column :addresses, :street_name
    add_column :addresses, :street_address, :string
  end
end
