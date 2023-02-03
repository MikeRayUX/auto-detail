class Washers::InvitationMailer < ApplicationMailer
  def send_email(washer, temp_password)
    @washer, @temp_password = washer, temp_password

    mail(
      to: @washer.email,
      subject: 'Your Invited to the Washer App! | FRESHANDTUMBLE',
      from: 'no-reply@freshandtumble.com'
    )
  end
end
