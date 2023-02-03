# frozen_string_literal: true

class AddAddressToCourierProblems < ActiveRecord::Migration[5.2]
  def change
    add_column :courier_problems, :address, :string
  end
end
