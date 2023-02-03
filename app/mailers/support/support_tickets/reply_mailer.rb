class Support::SupportTickets::ReplyMailer < ApplicationMailer
  def send_email(ticket, user, reply)
    @ticket, @user, @reply = ticket, user, reply
    @agent = User.new(
      full_name: 'Mike Arriaga'
    )

    mail(
			to: @ticket.customer_email,
			from: 'support@freshandtumble.com',
			subject: 'Support | FreshAndTumble'
		)
  end
end
