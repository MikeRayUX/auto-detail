# frozen_string_literal: true

class Api::V1::Users::Dashboards::HomesController < ApiController
  include Formattable
  # GET
  # api_v1_users_dashboards_homes_path
  # /api/v1/users/dashboards/homes
  def index
    @orders = @current_user.new_orders.in_progress

    @returned_orders = []

    if @orders.any?
      @orders.each do |o|
        @returned_orders.push({
          ref_code: o.ref_code,
          pickup_type: o.pickup_type,
          bag_price: readable_decimal(o.bag_price),
          bag_count: o.bag_count,
          subtotal: readable_decimal(o.subtotal),
          tax: readable_decimal(o.tax),
          tip: readable_decimal(o.tip),
          grandtotal: readable_decimal(o.grandtotal),
          est_delivery: readable_delivery(o.est_delivery),
          address: o.full_address.titleize,
          address_lat: o.address_lat,
          address_lng: o.address_lng,
        })
      end
    end

    render json: {
      code: 200,
      message: 'orders_returned',
      orders: @returned_orders,
      motd: "Welcome Back #{@current_user.first_name}!!"
    }
  end
end
