# Preview all emails at http://localhost:3000/rails/mailers/users/dashboards/support_ticket_received
class Users::Dashboards::SupportTicketReceivedPreview < ActionMailer::Preview
  def send_email
    @user = User.new(
      full_name: Faker::Name.name,
      email: Faker::Internet.email,
      phone: '3216549879',
      password: 'password',
      password_confirmation: 'password'
    )

    Users::Dashboards::SupportTicketReceivedMailer.send_email(
      @user
    )
  end
end
