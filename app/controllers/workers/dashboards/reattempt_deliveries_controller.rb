# frozen_string_literal: true

class Workers::Dashboards::ReattemptDeliveriesController < ApplicationController

  before_action :authenticate_worker!

  layout 'layouts/workers/dashboards/worker_dashboard_layout'

  def index
    @orders = Order.redeliveries.includes(:courier_problems).where(
      courier_problems:
        {
          occured_during_task: 'deliver_to_customer', occured_during_step: 'step3'
        }
    )
  end
end
