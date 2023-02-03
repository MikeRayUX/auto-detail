class AddStripeAccountIdToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :stripe_account_id, :string
  end
end
