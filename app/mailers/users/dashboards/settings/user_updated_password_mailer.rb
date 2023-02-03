# frozen_string_literal: true

class Users::Dashboards::Settings::UserUpdatedPasswordMailer < ApplicationMailer
  def send_email(user, timestamp)
    @user, @timestamp = user, timestamp

    mail(
      to: @user.email,
      subject: 'Fresh & Tumble - Your Password Was Changed'
    )
  end
end
