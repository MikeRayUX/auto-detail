# frozen_string_literal: true

class Api::V1::Users::ForgotPasswordsController < ApiController
  skip_before_action :authenticate_token!
  before_action :account_exists?
  before_action :valid_otp?, only: %i[update]
  before_action :passwords_match?, only: %i[update]

  # /api/v1/users/forgot_passwords/new
  # new_api_v1_users_forgot_passwords_path
  def new
    @token = @user.otp_code

    @user.send_forgot_password_email!

    render json: {
      code: 200,
      message: 'password_reset_email_sent',
      details: 'If an account exists with this email, a password recovery email has been sent to the email you provided'
    }
  end

  # /api/v1/users/forgot_passwords
  # api_v1_users_forgot_passwords_path
  def update
    @user.assign_attributes(
      password: user_params[:password],
      password_confirmation: user_params[:password_confirmation],
    )

    if @user.valid?
      @user.update(
        password: user_params[:password],
        password_confirmation: user_params[:password_confirmation]
      )
      render json: {
        code: 204,
        message: 'password_updated_successfully',
        details: 'Your Password has been updated Successfully!'
      }
    else
      render json: {
        code: 3000,
        message: 'invalid_password',
        errors: @user.errors.full_messages.first
      }
    end
  end
  
  private
  def user_params
    params.require(:user).permit(%i[
      email
      password
      password_confirmation
      otp_code
    ])
  end

  def account_exists?
    @user = User.find_by(email: user_params[:email])

    unless @user
      render json: {
        code: 200,
        message: 'password_reset_email_sent',
        details: 'If an account exists with this email, a password recovery email has been sent to the email you provided'
      }
    end
  end

  def valid_otp?
    unless @user.authenticate_otp(user_params[:otp_code], drift: Washer::RESET_PASSWORD_TIME_LIMIT.to_i)
      render json: {
        code: 3000,
        message: 'invalid_code',
        errors: 'The confirmation code you entered is either invalid or has expired'
      }
    end
  end

  def passwords_match?
    unless user_params[:password] == user_params[:password_confirmation]
      render json: {
        code: 3000,
        message: 'passwords_do_not_match',
        errors: 'The Password and Password Confirmation you entered, do not match.'
      }
    end
  end

end
