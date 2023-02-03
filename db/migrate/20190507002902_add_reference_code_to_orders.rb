# frozen_string_literal: true

class AddReferenceCodeToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :reference_code, :string
  end
end
