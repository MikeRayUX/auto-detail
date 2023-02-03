# frozen_string_literal: true

class AddStripeChargeIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :stripe_charge_id, :string
  end
end
