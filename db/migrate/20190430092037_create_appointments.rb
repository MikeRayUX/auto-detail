# frozen_string_literal: true

class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.belongs_to :order
      t.datetime :pick_up_date
      t.string :pick_up_window
      t.timestamps
    end
  end
end
