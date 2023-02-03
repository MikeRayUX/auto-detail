class Users::NewOrderMailer < ApplicationMailer
  def send_email(region, user, address, order)
    @region, @user, @address, @order = region, user, address, order

    mail(
      to: @user.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'Thank Your For Your Order | FreshAndTumble'
    )
  end
end
