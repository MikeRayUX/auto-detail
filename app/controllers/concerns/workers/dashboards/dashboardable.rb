# frozen_string_literal: true

module Workers::Dashboards::Dashboardable
  extend ActiveSupport::Concern

  protected

  def get_current_worker
    @worker = current_worker
  end

  # def get_current_stats
  #   @open_appointments_count = Order.not_started.count
  #   @orders_waiting_count = Order.picked_up.count
  #   @processing_count = Order.processing.count
  #   @out_for_delivery_count = Order.deliverable.count
  #   @completed_count = Order.delivered.count
  #   @cancelled_count = Order.cancelled.count
  #   @reattempt_count = Order.reattemptable.count
  #   @holding_count = Order.in_holding.count
  # end
end
