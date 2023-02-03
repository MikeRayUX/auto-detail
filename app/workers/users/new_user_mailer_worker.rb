# frozen_string_literal: true

class Users::NewUserMailerWorker
  include Sidekiq::Worker

  def perform(user_id)
    @user = User.find(user_id)

    Users::NewUserMailer.send_email(@user).deliver_now
  end
end
