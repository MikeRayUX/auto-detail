# frozen_string_literal: true

class Users::Dashboards::Settings::InfoSummariesController < ApplicationController

  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout'

  # users_dashboards_settings_info_summaries_path GET
  def show
  end
end