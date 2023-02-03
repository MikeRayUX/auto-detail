class AddStripeProcessingFeeToNewOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :new_orders, :pmt_processing_fee, :decimal, precision: 12, scale: 2
  end
end
