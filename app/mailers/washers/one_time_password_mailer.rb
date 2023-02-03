class Washers::OneTimePasswordMailer < ApplicationMailer
  def send_email(washer)
    @washer = washer

    mail(
      to: @washer.email,
      from:' no-reply@freshandtumble.com',
      subject: 'Your One Time Password'
    )
  end
end
