# frozen_string_literal: true

class Api::V1::Washers::ResendOtpsController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!

  # /api/v1/washers/resend_otps POST
  def create
    @washer = Washer.find_by(email: washer_params[:email])

    if @washer&.valid_password?(washer_params[:password]) && 
       @washer&.authenticate_with_otp?

       @washer.send_one_time_password_email!

      render json: {
        code: 200,
        message: "Please check your email: #{@washer.email} for a new One Time Password"
      }
    else
      render json: {
        code: 3000,
        message: 'failure',
        errors: "Cannot resend One Time Password, Please log in again.",
        status: :unauthorized
      }
    end
  end
  
  def washer_params
    params.require(:washer).permit(%i[
      email
      password])
  end
end
