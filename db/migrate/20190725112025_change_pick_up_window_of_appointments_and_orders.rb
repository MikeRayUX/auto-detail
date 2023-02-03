# frozen_string_literal: true

class ChangePickUpWindowOfAppointmentsAndOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :appointments, :pick_up_window, :pick_up_time
    rename_column :orders, :pick_up_window, :pick_up_time
    change_column :appointments, :pick_up_time, :string
    change_column :orders, :pick_up_time, :string
  end
end
