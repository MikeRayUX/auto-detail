# frozen_string_literal: true

class AddRolesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_admin, :boolean, default: false
    add_column :users, :is_worker, :boolean, default: false
    add_column :users, :is_client, :boolean, default: false
  end
end
