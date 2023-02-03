class Commercial::NewClientMailer < ApplicationMailer
  def send_email(client)
    @client = client

    mail(
      to: client.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Fresh And Tumble | Your New Account'
    )
  end

end
