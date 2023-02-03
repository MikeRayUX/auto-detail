# frozen_string_literal: true

class AddZipcodeToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :zipcode, :string
  end
end
