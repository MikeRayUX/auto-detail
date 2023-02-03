class AddLastViewedToSupportTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :support_tickets, :last_viewed, :datetime
  end
end
