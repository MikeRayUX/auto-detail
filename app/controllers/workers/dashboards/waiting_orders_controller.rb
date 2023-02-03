# frozen_string_literal: true

class Workers::Dashboards::WaitingOrdersController < ApplicationController

  before_action :authenticate_worker!

  layout 'workers/dashboards/worker_dashboard_layout'

  def index
    @orders = Order.picked_up.includes(:user)
    @commercial_pickups = CommercialPickup.picked_up
  end
end
