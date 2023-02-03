class RemovePartnerInvoiceNumberFromOrders < ActiveRecord::Migration[5.2]
	def change
		remove_column :orders, :partner_invoice_number
		remove_column :orders, :partner_grand_total
  end
end
