class AddUsersToSupportTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :support_tickets, :user_id, :integer
    add_column :support_tickets, :concern, :integer
  end
end
