# frozen_string_literal: true

class RemovePickUpDateFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :pick_up_date
  end
end
