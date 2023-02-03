# frozen_string_literal: true

class Api::V1::Users::Dashboards::AccountSettings::UpdateNamesController < ApiController

  # PATCH
  # api_v1_users_dashboards_account_settings_update_names_path
  # /api/v1/users/dashboards/account_settings/update_names
  def update
    if @current_user.update_attributes(user_params)
      render json: {
        code: 200,
        message: 'user_updated',
        feedback: 'Name updated successfully!',
        current_user: {
          full_name: @current_user.full_name.titleize,
          first_name: @current_user.first_name,
          email: @current_user.email.downcase
        },
      }
    else
      render json: {
        code: 3000,
        message: 'user_not_updated',
        errors: @current_user.errors.full_messages[0]
      }
    end
  end

  def user_params
    params.require(:user).permit(%i[full_name email phone])
  end
end
