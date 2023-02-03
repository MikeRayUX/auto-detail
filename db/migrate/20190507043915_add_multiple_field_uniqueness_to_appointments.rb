# frozen_string_literal: true

class AddMultipleFieldUniquenessToAppointments < ActiveRecord::Migration[5.2]
  def change
    add_index :appointments, %i[pick_up_date pick_up_window], unique: true
  end
end
