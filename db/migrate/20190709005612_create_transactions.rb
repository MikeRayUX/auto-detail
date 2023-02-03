# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.belongs_to :order
      t.belongs_to :user
      t.boolean :paid
      t.integer :transaction_type
      t.string :stripe_customer_id
      t.string :card_brand
      t.string :card_exp_month
      t.string :card_exp_year
      t.string :card_last4
      t.string :customer_email
      t.string :order_reference_code
      t.float :final_weight
      t.decimal :subtotal, precision: 12, scale: 2
      t.decimal :tax, precision: 12, scale: 2
      t.decimal :grandtotal, precision: 12, scale: 2
      t.decimal :deposit, precision: 12, scale: 2
      t.timestamps
    end
  end
end
