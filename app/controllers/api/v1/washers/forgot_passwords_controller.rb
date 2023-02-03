# frozen_string_literal: true

class Api::V1::Washers::ForgotPasswordsController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!
  before_action :account_exists?
  before_action :valid_otp?, only: %i[update]
  before_action :passwords_match?, only: %i[update]

  # /api/v1/washers/forgot_passwords/new
  # new_api_v1_washers_forgot_passwords_path
  def new
    @token = @washer.otp_code

    @washer.send_forgot_password_email!

    render json: {
      code: 200,
      message: 'password_reset_email_sent',
      details: 'If an account exists with this email, a password recovery email has been sent to the email you provided'
    }
  end

  # /api/v1/washers/forgot_passwords
  # api_v1_washers_forgot_passwords_path
  def update
    @washer.assign_attributes(
      password: washer_params[:password],
      password_confirmation: washer_params[:password_confirmation],
    )

    @washer.skip_finalized_washer_attributes = true
    if @washer.valid?

      @washer.assign_password(washer_params[:password])
      render json: {
        code: 204,
        message: 'password_updated_successfully',
        details: 'Your Password has been updated Successfully!'
      }
    else
      render json: {
        code: 3000,
        message: 'invalid_password',
        errors: @washer.errors.full_messages.first
      }
    end
  end
  
  private
  def washer_params
    params.require(:washer).permit(%i[
      email
      password
      password_confirmation
      otp_code
    ])
  end

  def account_exists?
    @washer = Washer.find_by(email: washer_params[:email])

    unless @washer
      render json: {
        code: 200,
        message: 'password_reset_email_sent',
        details: 'If an account exists with this email, a password recovery email has been sent to the email you provided'
      }
    end
  end

  def valid_otp?
    unless @washer.authenticate_otp(washer_params[:otp_code], drift: Washer::RESET_PASSWORD_TIME_LIMIT.to_i)
      render json: {
        code: 3000,
        message: 'invalid_code',
        errors: 'The confirmation code you entered is either invalid or has expired'
      }
    end
  end

  def passwords_match?
    unless washer_params[:password] == washer_params[:password_confirmation]
      render json: {
        code: 3000,
        message: 'passwords_do_not_match',
        errors: 'The Password and Password Confirmation you entered, do not match.'
      }
    end
  end

end
