# frozen_string_literal: true

class Api::V1::Users::Dashboards::AccountSettings::UpdatePasswordsController < ApiController
  before_action :valid_password?
  before_action :new_passwords_match?

  # PATCH
  # api_v1_users_dashboards_account_settings_update_passwords_path
  # /api/v1/users/dashboards/account_settings/update_passwords
  def update
    if @current_user.update(password: password_params[:new_password], password_confirmation: password_params[:new_password_confirmation])
      # password changed MAILER
      render(json: {
               code: 204,
               message: 'password_updated',
               feedback: 'Your password has been updated successfully!'
             })
    else
      render(json: {
               code: 3000,
               message: 'invalid_password',
               errors: @current_user.errors.full_messages.first
             })
    end
  end

  private

  def valid_password?
    unless @current_user.valid_password?(password_params[:old_password])
      render json: {
        code: 3000,
        message: 'invalid_password',
        errors: 'Invalid Password.'
      }
    end
  end

  def new_passwords_match?
    unless password_params[:new_password] === password_params[:new_password_confirmation]
      render json: {
        code: 3000,
        message: 'invalid_password',
        errors: 'Passwords do not match.'
      }
    end
  end

  def password_params
    params.require(:password).permit(:old_password, :new_password, :new_password_confirmation)
  end
end
