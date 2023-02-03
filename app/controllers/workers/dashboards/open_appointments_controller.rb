# frozen_string_literal: true
class Workers::Dashboards::OpenAppointmentsController < ApplicationController

  before_action :authenticate_worker!

  layout 'workers/dashboards/worker_dashboard_layout'

  # workers_dashboards_open_appointments_path GET
  def index
    @orders = Order.not_started.includes(:user).order('DATE(pick_up_date) ASC, pick_up_time desc').limit(200)
    @commercial_pickups = CommercialPickup.not_started.limit(200)
  end
end
