class Api::V1::Users::Dashboards::NewOrderFlow::AsapPickupsController < Api::V1::OrderableController
  include CalculateChargable

  layout 'users/dashboards/new_order_flow/order_layout'

  # /api/v1/users/dashboards/new_order_flow/asap_pickups/new
  # new_api_v1_users_dashboards_new_order_flow_asap_pickup_path
  def new
    @address = @current_user.address
    @region = @address.region
    @order = build_with_charge

    @order.skip_charge_validate = true
    
    if @order.valid?
      @minutes = rand(55..65)
      @estimate = NewOrder.gen_pickup_estimate

      @readable_estimate = @estimate.strftime('%I:%M%P').upcase
      if @readable_estimate.first == '0'
        @readable_estimate = @readable_estimate[1...@readable_estimate.length]
      end

      render json: {
        code: 200,
        message: 'order_valid',
        confirmed_order: {
          pickup_type: @order.pickup_type,
          bag_count: @order.bag_count,
          subtotal: @order.subtotal,
          tax: @order.tax, 
          tax_rate: @order.tax_rate,
          readable_scheduled: @order.short_readable_scheduled,
          readable_tax_rate: @region.tax_rate_percentage,
          est_delivery: @order.readable_est_delivery,
          detergent: @order.detergent,
          softener: @order.softener,
          readable_detergent: @order.short_detergent,
          readable_softener: @order.short_softener,
          readable_estimate: @readable_estimate
        },
        tips_for_select: NewOrder::TIP_OPTIONS
      }
      
    else
      render json: {
        code: 3000,
        message: 'invalid_order',
        errors: @order.errors.full_messages.first
      }
    end
  end

  # /api/v1/users/dashboards/new_order_flow/asap_pickups
  # api_v1_users_dashboards_new_order_flow_asap_pickups_path
  def create
    @address = @current_user.address
    @region = @address.region

    @order = build_with_charge
    @order.skip_charge_validate = true

    if @order.valid?
      @order.charge_order!(@current_user)
      @order.save!
      @order.send_new_order_email!(@region, @current_user, @address)
      @order.alert_washers_in_region!

      render json: {
        code: 201,
        message: 'order_created_successfully',
        ref_code: @order.ref_code
      }
    else
      render json: {
        code: 3000,
        message: 'order_failed',
        errors: @order.errors.full_messages.first
      }
    end

    rescue Stripe::StripeError => e
      render json: {
        code: 3000,
        message: 'stripe_error',
        errors: e
      }
  end

  # /users/dashboards/new_order_flow/asap_pickups/:id
  # users_dashboards_new_order_flow_asap_pickup_path
  def show
    @order = @current_user.new_orders.find_by(ref_code: params[:id])
  end

  private
  def new_order_params
    params.require(:new_order).permit(%i[
      pickup_type
      detergent
      softener
      bag_count
      tip
    ])
  end
end