# frozen_string_literal: true

class Api::V1::Washers::OtpSessionsController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!

  # /api/v1/washers/otp_sessions POST
  def create
    @washer = Washer.find_by(email: washer_params[:email])

    if @washer&.valid_password?(washer_params[:password]) && 
       @washer&.authenticate_with_otp? &&
       @washer.authenticate_otp(washer_params[:otp_code], drift: 2.hours.to_i)

      @washer.disable_authenticate_with_otp

      @token = JsonWebToken.encode(sub: @washer.email)
      render json: {
        code: 200,
        message: 'success',
        washer: {
          full_name: @washer.full_name.upcase,
          email: @washer.email
        },
        auth_token: @token
      }
    else
      render json: {
        code: 3000,
        message: 'failure',
        errors: "Invalid Password or One-Time-Password Code",
        status: :unauthorized
      }
    end
  end
  
  def washer_params
    params.require(:washer).permit(%i[
      email
      password
      otp_code])
  end
end
