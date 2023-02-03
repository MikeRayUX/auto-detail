# frozen_string_literal: true

class Users::Dashboards::Settings::UserUpdatedPasswordMailerWorker
  include Sidekiq::Worker

  def perform(user_id, timestamp)
    @user = User.find(user_id)
    @timestamp = timestamp

    Users::Dashboards::Settings::UserUpdatedPasswordMailer.send_email(
      @user,
      @timestamp
    ).deliver_later
  end
end
