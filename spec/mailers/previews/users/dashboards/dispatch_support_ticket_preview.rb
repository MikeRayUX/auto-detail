# Preview all emails at http://localhost:3001/rails/mailers/users/dashboards/dispatch_support_ticket
class Users::Dashboards::DispatchSupportTicketPreview < ActionMailer::Preview

  def send_email
    @ticket = SupportTicket.new(
      order_id: 1,
      subject: 'New Support Ticket | Order: LB-123445',
      body: "My order got lost and I don't know what to do",
      order_reference_code: 'LB-123445',
      customer_name: 'Mike Arriaga',
      customer_email: 'arriaga562@gmail.com',
      customer_phone: '5627872684',
      pick_up_appointment: 'Friday 13th at 7:30AM'
    )

    Users::Dashboards::DispatchSupportTicketMailer.send_email(@ticket)
  end

end
