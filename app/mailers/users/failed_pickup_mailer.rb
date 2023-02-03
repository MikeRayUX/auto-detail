class Users::FailedPickupMailer < ApplicationMailer
  def send_email(order, offer_event, user, failed_pickup_fee)
    @order, @offer_event, @user, @failed_pickup_fee = order, offer_event, user, failed_pickup_fee

    mail(
      to: @user.email,
      from: 'no-reply@freshandtumble.com',
      subject: "We were unable to pickup your order | FRESHANDTUMBLE"
    )
  end
end
