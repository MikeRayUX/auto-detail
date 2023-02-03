# frozen_string_literal: true

class Workers::Dashboards::ProcessingOrdersController < ApplicationController

  before_action :authenticate_worker!

  layout 'workers/dashboards/worker_dashboard_layout'

  def index
    @orders = Order.processing.includes(:user, :partner_location)
    @commercial_pickups = CommercialPickup.processing.includes(:client, :partner_location)
  end
end
