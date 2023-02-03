class Washers::ApplicationReceivedMailer < ApplicationMailer

  def send_email(washer, region)
    @washer, @region = washer, region

    mail(
      to: washer.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Application Received'
    )
  end
end
