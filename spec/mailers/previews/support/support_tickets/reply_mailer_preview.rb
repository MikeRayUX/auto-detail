# Preview all emails at http://localhost:3001/rails/mailers/support/support_tickets/reply
class Support::SupportTickets::ReplyPreview < ActionMailer::Preview

  def send_email
    @user = User.new(
      id: 99,
      full_name: 'Mike Arriaga',
      email: 'sample@sample.com'
    )

    @ticket = SupportTicket.new(
      id: 99,
      order_reference_code: "LB-#{SecureRandom.hex(5)}".upcase,
      user_id: @user.id,
      concern: SupportTicket.concerns.to_a.sample.first,
      body: random_body
    )
    
    @reply = SupportTicketReply.new(
      id: 99,
      support_ticket_id: @ticket.id,
      body: random_body
    )

    @agent = User.new(
      full_name: 'Mike Arriaga'
    )
    
    @mailer = Support::SupportTickets::ReplyMailer.send_email(
      @ticket,
      @user,
      @reply
    )
  end

end


def random_body
  @body = "" 
  rand(1..3).times do
    @body += "#{Faker::Quote.matz}\n"
  end

  @body
end
