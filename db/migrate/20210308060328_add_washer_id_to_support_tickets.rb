class AddWasherIdToSupportTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :support_tickets, :washer_id, :bigint
    add_index :support_tickets, :washer_id
  end
end
