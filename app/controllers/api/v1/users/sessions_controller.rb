# frozen_string_literal: true

class Api::V1::Users::SessionsController < ApiController
  skip_before_action :authenticate_token!, only: :create

  include Formattable

  # POST
  # api_v1_users_sessions_path
  # /api/v1/users/sessions
  def create
    # sleep 1.seconds
    @user = User.find_by(email: user_params[:email])
    if @user&.valid_password?(user_params[:password])
      @token = JsonWebToken.encode(sub: @user.id)
      @address = @user.address

      render json: {
        code: 200,
        message: 'success',
        data: {
          token: @token
        },
        current_user: {
          full_name: @user.full_name.titleize,
          first_name: @user.first_name,
          email: @user.email.downcase
        },
        current_address: @address ? 
        {
          full_address: @address.full_address.upcase,
          pick_up_directions: @address.pick_up_directions,
          truncated_address: truncate_attribute(@address.street_address, 35).upcase,
          lat: @address.latitude,
          lng: @address.longitude 
        } : nil
      }
    else
      render json: {
        code: 3000,
        message: 'failure',
        data: {
          errors: 'Invalid Email and/or Password'
        },
        status: :unauthorized
      }
    end
  end

  # DELETE
  # api_v1_users_sessions_path
  # /api/v1/users/sessions
  def destroy
    @token = JsonWebToken.decode(auth_token).first

    if JwtBlacklist.create!(jti: @token['jti'])
      render json: {
        code: 200,
        message: 'success'
      }
    end
  end

  private

  def auth_token
    @auth_token ||= request.headers.fetch('Authorization', '').split(' ').last
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
