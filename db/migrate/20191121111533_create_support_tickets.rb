class CreateSupportTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :support_tickets do |t|
      t.belongs_to :order
      t.string :subject
      t.string :body
      t.string :order_reference_code
      t.string :customer_name
      t.string :customer_email
      t.string :customer_phone
      t.string :pick_up_appointment
      t.timestamps
    end
  end
end