class Api::V1::Users::Dashboards::AccountSettings::NotificationsPreferencesController < ApiController

  # GET
  # api_v1_users_dashboards_account_settings_notifications_preferences_path
  # /api/v1/users/dashboards/account_settings/notifications_preferences	
  def index
    # sleep 1.seconds
    if @current_user.present?
      render json: {
        code: 200,
        message: 'preferences_returned',
        sms_enabled: @current_user.sms_enabled,
        promotional_emails: @current_user.promotional_emails
      }
    else
      render json: {
        code: 200,
        message: 'failure',
        errors: 'Something went wrong.'
      }
    end
  end

  # PATCH
  # api_v1_users_dashboards_account_settings_notifications_preference_path
  #/api/v1/users/dashboards/account_settings/notifications_preferences/1
  def update
    # sleep 2.seconds
    if @current_user.update_attributes(notification_params)
      render json: {
        code: 200,
        message: 'updated_successfully',
        sms_enabled: @current_user.sms_enabled,
        promotional_emails: @current_user.promotional_emails
      }
    else
      render json: {
        code: 3000,
        message: 'failure',
        data: {
          errors: @current_user.errors.full_messages[0]
        }
      }
    end
  end

  private

  def notification_params
    params.require(:preference).permit(:sms_enabled, :promotional_emails)
  end

end
