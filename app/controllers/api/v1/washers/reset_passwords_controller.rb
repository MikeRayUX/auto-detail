class Api::V1::Washers::ResetPasswordsController < Api::V1::Washers::AuthsController
  before_action :current_password_valid?
  # before_action :secure_password

  # api_v1_washers_reset_passwords_path
  # /api/v1/washers/reset_passwords
  def update
    @current_washer.skip_finalized_washer_attributes = true
    if @current_washer.update(
      password: password_change_params[:new_password],
      password_confirmation: password_change_params[:new_password_confirmation],
    )
      render json: {
        code: 204,
        message: 'password_updated',
        details: 'Your Password Was Updated Successfully'
      }
    else
      render json: {
        code: 3000,
        message: 'invalid_password',
        errors: @current_washer.errors.full_messages.first
      }
    end
  end
  
  private
  def password_change_params
    params.require(:password_change).permit(%i[
      current_password
      new_password
      new_password_confirmation
      ])
  end

  def current_password_valid?
    unless @current_washer.valid_password?(password_change_params[:current_password])
      render json: {
        code: 3000,
        message: 'invalid_current_password',
        errors: 'Invalid Password'
      }
    end
  end


end