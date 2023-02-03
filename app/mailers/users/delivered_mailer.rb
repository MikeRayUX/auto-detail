class Users::DeliveredMailer < ApplicationMailer
  def send_email(order, user)
    @order, @user = order, user

    mail(
      to: @user.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Your Laundry Was Delivered!'
    )
  end
end
