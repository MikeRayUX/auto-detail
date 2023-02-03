# frozen_string_literal: true

class AddInvoiceFieldsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :partner_invoice_number, :string
    add_column :orders, :partner_grand_total, :decimal, precision: 12, scale: 2
  end
end
