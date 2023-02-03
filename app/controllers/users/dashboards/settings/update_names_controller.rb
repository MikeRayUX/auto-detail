# frozen_string_literal: true

class Users::Dashboards::Settings::UpdateNamesController < ApplicationController
  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout', only: %i[show]

  # users_dashboards_settings_update_names_path GET
  def show

  end

  # users_dashboards_settings_update_names_path PUT
  def update
    if current_user.update_attributes(user_params)
      redirect_to users_dashboards_settings_info_summaries_path, flash: {
        notice: "Updated Successfully!"
      }
    else
      redirect_to users_dashboards_settings_update_names_path, flash: {
        notice: current_user.errors.full_messages.first
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name)
  end
end
