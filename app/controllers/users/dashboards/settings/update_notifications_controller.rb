class Users::Dashboards::Settings::UpdateNotificationsController < ApplicationController

  before_action :authenticate_user!
  layout 'users/dashboards/user_dashboard_layout'
  
  # users_dashboards_settings_update_notifications_path GET
  def show
  end

  # users_dashboards_settings_update_notifications_path PUT
  def update
    if current_user.update_attributes(notification_params)
      redirect_to users_dashboards_settings_info_summaries_path, flash: {
        success: "Updated Successfully!"
      }
    else
      redirect_to users_dashboards_settings_update_notifications_path, flash: {
        error: "Something went wrong. Please try again."
      }
    end
  end

  private

  def notification_params
    params.require(:notifications).permit(:sms_enabled, :promotional_emails)
  end
end
