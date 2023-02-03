class CreateSupportTicketReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :support_ticket_replies do |t|
      t.belongs_to :support_ticket
      t.string :body

      t.timestamps
    end
  end
end
