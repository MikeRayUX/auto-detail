# frozen_string_literal: true

class Workers::Dashboards::ProcessingOrderReadyStatesController < ApplicationController
  before_action :authenticate_worker!

  def update
    @order = Order.find_by(reference_code: params[:id])
    @option = params[:option]

    if @option == 'ready'
      @order.update_attribute(
        :marked_as_ready_for_pickup_from_partner, true
      )
      redirect_to workers_dashboards_processing_orders_path, flash: {
        notice: "Order: #{@order.reference_code} has been marked as ready."
      }
    else
      @order.update_attribute(
        :marked_as_ready_for_pickup_from_partner, false
      )
      redirect_to workers_dashboards_processing_orders_path, flash: {
        notice: "Order: #{@order.reference_code} has been marked as not ready."
      }
    end
  end
end
