class Api::V1::Users::Dashboards::AccountSettings::UpdatePhonesController < ApiController
  # frozen_string_literal: true

  # /api/v1/users/dashboards/account_settings/update_phones
  # api_v1_users_dashboards_account_settings_update_phones_path
  def update
    if @current_user.update_attributes(phone: phone_params[:phone])
      render json: {
        code: 204,
        message: 'phone_updated_successfully',
        feedback: 'Phone updated successfully!',
        current_user: {
          full_name: @current_user.full_name.titleize,
          first_name: @current_user.first_name,
          email: @current_user.email.downcase,
          phone: @current_user.formatted_phone,
        },
      }
    else
      render json: {
        code: 3000,
        message: 'phone_invalid',
        errors: @current_user.errors.full_messages.first
      }
    end
  end

  private

  def phone_params
    params.require(:user).permit(:phone)
  end
end
