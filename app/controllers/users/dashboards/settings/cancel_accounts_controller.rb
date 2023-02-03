# frozen_string_literal: true

class Users::Dashboards::Settings::CancelAccountsController < ApplicationController

  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout'

  # new_users_dashboards_settings_cancel_accounts_path GET
  def new
  end

  # users_dashboards_settings_cancel_accounts_path POST
  def create
    if questionaire_filled_out?
      @questionaire = current_user.questionaires.create(answer_params)
    end
    
    current_user.soft_delete
    redirect_to signin_path, flash: {
      alert: 'Your account has been cancelled.'
    }
  end

  private

  def answer_params
    params.require(:questionaire).permit(
      :subject,
      :answer_selection,
      :elaboration
    )
  end

  def questionaire_filled_out?
    answer_params[:subject].present? && answer_params[:answer_selection].present?
  end
end
