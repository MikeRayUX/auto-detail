# frozen_string_literal: true

class AddStripeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_id, :string
  end
end
