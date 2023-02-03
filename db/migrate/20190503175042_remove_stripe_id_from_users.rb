# frozen_string_literal: true

class RemoveStripeIdFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :stripe_token
  end
end
