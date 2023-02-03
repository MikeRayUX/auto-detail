class Users::CancelledNewOrderMailer < ApplicationMailer
  def send_email(user, order)
    @user, @order = user, order

    mail(
      to: @user.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Your Order Has Been Cancelled | FreshAndTumble'
    )
  end
end
