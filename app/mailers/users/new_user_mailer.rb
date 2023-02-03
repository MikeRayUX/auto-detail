# frozen_string_literal: true

class Users::NewUserMailer < ApplicationMailer
  def send_email(user)
    @user = user

    mail(to: user.email, subject: 'Welcome to Fresh & Tumble!')
  end
end
