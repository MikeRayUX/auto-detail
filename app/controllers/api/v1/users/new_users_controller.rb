# frozen_string_literal: true

class Api::V1::Users::NewUsersController < ApiController
  skip_before_action :authenticate_token!

  # POST
  # api_v1_users_new_users_path
  # /api/v1/users/new_users
  def create
    # sleep 1.seconds
    @user = User.new(user_params)
    if @user.valid?
      @user.save!

      Users::NewUserMailerWorker.perform_async(@user.id)

      @token = JsonWebToken.encode(
        sub: @user.id,
        email: @user.email
      )
      render(json: {
               status: 'ok',
               code: 200,
               token: @token,
               message: 'user_created'
             })
    else
      render(json: {
               status: 'ok',
               code: 3000,
               message: @user.errors.full_messages[0]
             })
    end
  end

  private
  def user_params
    params.require(:user).permit(:full_name, :email, :phone, :password, :password_confirmation)
  end
end
