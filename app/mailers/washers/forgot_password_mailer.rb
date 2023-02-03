class Washers::ForgotPasswordMailer < ApplicationMailer

  def send_email(washer)
    @washer = washer

    mail(
      to: @washer.email,
      subject: 'Reset Your Password',
      from: 'no-reply@freshandtumble.com'
    )
  end
end
