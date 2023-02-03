class Users::Dashboards::Settings::UpdateSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :subscription_expired?, only: %i[show]
  layout 'users/dashboards/user_dashboard_layout'
  
  # users_dashboards_settings_update_subscriptions_path GET
  def show
    @subscription = Subscription.first
  end

  # cancel
  # /users/dashboards/settings/update_subscriptions
  # users_dashboards_settings_update_subscriptions_path
  # DELETE
  def destroy
    if current_user.has_active_subscription?
      current_user.cancel_subscription!
      current_user.send_subscription_cancel_email!
      
      redirect_to users_dashboards_settings_update_subscriptions_path, flash: {
        notice: 'Your subscription has been cancelled successfully.'
      }
    else
      redirect_to users_dashboards_settings_update_subscriptions_path, flash: {
        notice: "You don't have an active subscription to cancel"
      }
    end

  rescue Stripe::StripeError => e
    redirect_to users_dashboards_settings_update_subscriptions_path, flash: {
      notice: 'Something went wrong.'
    }
  end

  private
  def subscription_expired?
    unless current_user.has_active_subscription?
      redirect_to users_resolve_subscriptions_path
    end
  end
end
