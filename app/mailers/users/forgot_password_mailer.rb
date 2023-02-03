class Users::ForgotPasswordMailer < ApplicationMailer
  def send_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: 'Reset Your Password',
      from: 'no-reply@freshandtumble.com'
    )
  end
end
