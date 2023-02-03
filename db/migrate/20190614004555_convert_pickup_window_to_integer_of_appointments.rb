# frozen_string_literal: true

class ConvertPickupWindowToIntegerOfAppointments < ActiveRecord::Migration[5.2]
  def change
    change_column :appointments, :pick_up_window, 'integer USING CAST(pick_up_window AS integer)'
  end
end
