# frozen_string_literal: true

class Users::Dashboards::Settings::UpdateEmailsController < ApplicationController
  # include Users::Dashboards::UpdateUserInfo

  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout', only: %i[show]

  # users_dashboards_settings_update_emails_path GET
  def show; end

  # users_dashboards_settings_update_emails_path PUT
  def update
    if current_user.update_attributes(email: email_params[:email])

      if current_user.has_payment_method?
        current_user.update_stripe_customer_email
      end

      redirect_to users_dashboards_settings_info_summaries_path, flash: {
        notice: "Updated Successfully!"
      }
    else
      redirect_to users_dashboards_settings_update_emails_path, flash: {
        notice: current_user.errors.full_messages.first
      }
    end

  rescue Stripe::StripeError => e
    redirect_to users_dashboards_settings_update_emails_path, flash: {
      notice: e.message
    }
  end

  private

  def email_params
    params.require(:email).permit(:email)
  end
end
