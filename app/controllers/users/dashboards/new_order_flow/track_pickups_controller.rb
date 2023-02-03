class Users::Dashboards::NewOrderFlow::TrackPickupsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :ensure_order_exists, only: %i[index]
  before_action :offer_not_cancelled?, only: %i[index]
  before_action :offer_not_expired?, only: %i[index]

  layout 'users/dashboards/new_order_flow/order_layout'

  # GET
  # /users/dashboards/new_order_flow/track_pickups/:id
  # users_dashboards_new_order_flow_track_pickup_path
  def show
    @order = current_user.new_orders.find_by(ref_code: params[:id])
    if @order
      @user = @order.user
      @address = @user.address
    end
  end

  # /users/dashboards/new_order_flow/track_pickups
  # users_dashboards_new_order_flow_track_pickup_path
  # get status
  def index
    if !@order.picked_up_at
      @estimate = @order.est_pickup_by.strftime('%I:%M%P').upcase
    else
      @estimate = nil
    end

    if @order.washer_trackable?
      render json: {
        code: 200,
        message: 'order_returned',
        ref_code: @order.ref_code,
        order_status: @order.status,
        customer_status: @order.customer_status,
        delivery_photo_base64: @order.delivery_photo_base64,
        readable_delivered: @order.readable_delivered,
        readable_delivery_location: @order.readable_delivery_location,
        est_pickup_by: @estimate,
        cancellable: @order.cancellable?,
        washer: {
          name: @order.washer.abbrev_name,
          location: {
            lat: @order.washer.current_lat,
            lng: @order.washer.current_lng
          } 
        }
      }
    else
      render json: {
        code: 200,
        message: 'order_returned',
        ref_code: @order.ref_code,
        order_status: @order.status,
        delivery_photo_base64: @order.delivery_photo_base64,
        readable_delivered: @order.readable_delivered,
        readable_delivery_location: @order.readable_delivery_location,
        est_pickup_by: @estimate,
        cancellable: @order.cancellable?,
        customer_status: @order.customer_status,
        washer: nil
      }
    end
  end

  def ensure_order_exists
    @order = current_user.new_orders.find_by(ref_code: params[:id])
    unless @order
      render json: {  
        code: 3000,
        message: 'order_not_found',
        order_status: 'order_not_found'
      }
    end
  end

  def offer_not_cancelled?
    unless @order.not_cancelled?
      render json: {
        code: 200,
        message: 'order_returned',
        ref_code: @order.ref_code,
        order_status: 'cancelled',
        cancellable: false,
        customer_status: @order.customer_status,
        washer: nil
      }
    end
  end

  def offer_not_expired?
    unless @order.offer_not_expired?
      render json: {
        code: 3000,
        message: 'offer_expired',
        order_status: 'offer_expired',
        cancellable: @order.cancellable?,
        errors: "This order has expired."
      }
    end
  end

  # def new_order_params
  #   params.require(:new_order).permit(%i[ref_code])
  # end
end