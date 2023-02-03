class Users::Dashboards::Settings::UpdatePhonesController < ApplicationController
  # frozen_string_literal: true
  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout', only: %i[show]
  
  # users_dashboards_settings_update_phones_path GET
  def show; end

  # users_dashboards_settings_update_phones PUT
  def update
    if current_user.update_attributes(phone: phone_params[:phone])

      redirect_to users_dashboards_settings_info_summaries_path, flash: {
        notice: "Updated Successfully!"
      }
    else
      redirect_to users_dashboards_settings_update_phones_path, flash: {
        notice: current_user.errors.full_messages.first
      }
    end

  rescue Stripe::StripeError => e
    redirect_to users_dashboards_settings_update_phones_path, flash: {
      notice: e.message
    }
  end

  private

  def phone_params
    params.require(:phone).permit(:phone)
  end
end
