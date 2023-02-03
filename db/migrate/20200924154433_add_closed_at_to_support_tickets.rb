class AddClosedAtToSupportTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :support_tickets, :closed_at, :datetime
  end
end
