# frozen_string_literal: true

class AddDetergentPreferenceToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :detergent_preference, :integer
  end
end
