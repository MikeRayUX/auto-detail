# frozen_string_literal: true

class Api::V1::Washers::SessionsController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!
  before_action :authenticated?, only: %i[create]
  before_action :is_invited?, only: %i[create]
  before_action :is_not_deactivated?, only: %i[create]

  # /api/v1/washers/sessions POST
  def create
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
  end
  
  # # /api/v1/washers/sessions DELETE
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
  def washer_params
    params.require(:washer).permit(%i[email password])
  end

  def authenticated?
    @washer = Washer.find_by(email: washer_params[:email])
    unless @washer&.valid_password?(washer_params[:password])
      render json: {
        code: 3000,
        message: 'failure',
        errors: "Invalid Email and/or Password",
        status: :unauthorized
      }
    end
  end
  
  def is_invited?
    unless @washer.invited?
      render json: {
        code: 3000,
        message: 'failure',
        errors: 'This account has not yet received an invitation. Once invited, you will receive an invitation email.'
      }
    end
  end

  def is_not_deactivated?
    unless @washer.not_deactivated?
      render json: {
        code: 3000,
        message: 'failure',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com'
      }
    end
  end


  def auth_token
    @auth_token ||= request.headers.fetch('Authorization', '').split(' ').last
  end

  
end
