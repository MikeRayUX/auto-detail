class Users::SubscriptionCancelMailer < ApplicationMailer

  def send_email(user)
    @user = user
   
    mail(
      to: @user.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Subscription Cancelled | FRESHANDTUMBLE'
    )
  end
end
