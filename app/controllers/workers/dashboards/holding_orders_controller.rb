# frozen_string_literal: true

class Workers::Dashboards::HoldingOrdersController < ApplicationController

  before_action :authenticate_worker!
  
  layout 'workers/dashboards/worker_dashboard_layout'

  # workers_dashboards_holding_orders_path GET
  def index
    @orders = Order.where(
      global_status: 'in_holding_unable_to_deliver'
    ).includes(:courier_problems).where(
      courier_problems:
      {
        occured_during_task: 'deliver_to_customer',
        occured_during_step: 'step3'
      }
    )
  end
end
