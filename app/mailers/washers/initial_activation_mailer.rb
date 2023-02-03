class Washers::InitialActivationMailer < ApplicationMailer

  def send_email(washer)
    @washer = washer

    mail(
      to: @washer.email,
      subject: 'Woo Hoo! Your Washer Account is now Activated!',
      from: 'no-reply@freshandtumble.com'
    )
  end
end
