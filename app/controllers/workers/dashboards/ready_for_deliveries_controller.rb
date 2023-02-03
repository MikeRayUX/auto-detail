# frozen_string_literal: true

class Workers::Dashboards::ReadyForDeliveriesController < ApplicationController
  before_action :authenticate_worker!

  layout 'workers/dashboards/worker_dashboard_layout'

  # workers_dashboards_ready_for_deliveries_path GET
  def index
    @orders = Order.where(global_status: %w[ready_for_delivery out_for_delivery]).includes(:user, :partner_location)
    @commercial_pickups = CommercialPickup.deliverable.includes(:client)
  end
end
