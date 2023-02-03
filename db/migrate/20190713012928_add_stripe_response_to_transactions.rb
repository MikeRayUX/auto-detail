# frozen_string_literal: true

class AddStripeResponseToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :stripe_response, :string
  end
end
