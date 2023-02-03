# frozen_string_literal: true

class RemoveClientIdFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :client_id
  end
end
