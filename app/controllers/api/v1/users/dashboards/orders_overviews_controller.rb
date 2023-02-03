class Api::V1::Users::Dashboards::OrdersOverviewsController < ApiController
  before_action :has_orders?
  include Formattable
  # GET
  # api_v1_users_dashboards_orders_overviews_path
  # /api/v1/users/dashboards/orders_overviews
  def index
    @orders_array = []
    @orders.each do |o|
      @orders_array.push({
        ref_code: o.ref_code,
        created_at: readable_date(o.created_at),
        grandtotal: readable_decimal(o.grandtotal),
        bag_count: o.bag_count,
        scheduled: o.readable_scheduled,
        readable_status: o.readable_status,
        detergent: o.short_detergent,
        softener: o.short_softener,
        est_delivery: o.readable_est_delivery,
        readable_delivered: o.readable_delivered
      })
    end
    render json: {
      code: 200,
      message: 'has_orders',
      orders: @orders_array
    }
  end

  private
  def has_orders?
    @orders = @current_user.new_orders.order(created_at: :desc)
    unless @orders.any?
      render json: {
        code: 200,
        message: 'no_orders'
      }
    end
  end
end
