# frozen_string_literal: true

class Users::Dashboards::Settings::UpdatePaymentsController < ApplicationController
  before_action :authenticate_user!

  layout 'users/dashboards/stripe_layout'

  include Users::Dashboards::UpdateUserInfo

  # /users/dashboards/settings/update_payments
  # users_dashboards_settings_update_payments_path GET
  def show; end

  # users_dashboards_settings_update_payments_path PUT
  def update
    if current_user.has_payment_method?
      current_user.update_stripe_payment_method(card_params)
      flash[:notice] = "Payment method successfully updated!"
    else
      current_user.create_stripe_customer!(card_params)
      flash[:notice] = "Payment method saved!"
    end

    redirect_to users_dashboards_settings_update_payments_path
  rescue Stripe::StripeError => e
    redirect_to users_dashboards_settings_update_payments_path, flash: {
      alert: e.message
    }
  end

  private

  def card_params
    params.require(:card).permit(:card_brand, :card_exp_month, :card_exp_year, :card_last4, :stripe_token)
  end
end
