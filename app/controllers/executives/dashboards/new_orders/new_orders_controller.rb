class Executives::Dashboards::NewOrders::NewOrdersController < ApplicationController
  before_action :authenticate_executive!
  layout 'executives/dashboard_layout'

  # executives_dashboards_new_orders_new_orders_path GET
  def index
    @today_profit = NewOrder.today.delivered.sum(:profit)
    if params[:sorted].present?
      case params[:sorted]
      when 'all'
        @orders = NewOrder.all.includes(:user, :washer).newest.page(params[:page]).per(50)
      when 'in_progress'
        @orders = NewOrder.in_progress.newest.page(params[:page]).per(50)
      when 'newest'
        @orders = NewOrder.all.includes(:user, :washer).newest.page(params[:page]).per(50)
      when 'oldest'
        @orders = NewOrder.all.includes(:user, :washer).oldest.page(params[:page]).per(50)
      when 'delivered'
        @orders = NewOrder.delivered.order(created_at: :desc).newest.page(params[:page]).per(50)
      when 'expired'
        @orders = NewOrder.expired.newest.page(params[:page]).per(50)
      when 'cancelled'
        @orders = NewOrder.cancelled.newest.page(params[:page]).per(50)
      else
        @orders = NewOrder.all.includes(:user, :washer).newest.page(params[:page]).per(50)
      end
    else
      @orders = NewOrder.all.includes(:user, :washer).newest.page(params[:page]).per(50)
    end
  end

  # executives_dashboards_new_orders_new_order_path
  def show
    @order = NewOrder.find_by(ref_code: params[:id])
    @events = @order.offer_events.order(created_at: :asc)
  end

end