# frozen_string_literal: true

class RemoveActiveFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :active
  end
end
