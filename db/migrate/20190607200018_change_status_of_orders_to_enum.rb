# frozen_string_literal: true

class ChangeStatusOfOrdersToEnum < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :status

    add_column :orders, :status, :integer
  end
end
