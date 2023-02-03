# frozen_string_literal: true

class RemoveRolesFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_admin
    remove_column :users, :is_worker
    remove_column :users, :is_client
  end
end
