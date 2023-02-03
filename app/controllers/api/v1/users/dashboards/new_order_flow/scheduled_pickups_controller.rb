class Api::V1::Users::Dashboards::NewOrderFlow::ScheduledPickupsController < Api::V1::OrderableController
  # after_action :debug_undo, only: %i[create]
  include CalculateChargable
  # new_api_v1_users_dashboards_new_order_flow_scheduled_pickup_path
  # /api/v1/users/dashboards/new_order_flow/scheduled_pickups/new
  def new
    @address = @current_user.address
    @region = @address.region
    @order = build_with_charge

    @order.skip_charge_validate = true

    @pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{new_order_params[:pickup_date]},#{new_order_params[:pickup_time]}")

    @order.assign_attributes(
      accept_by: @pickup_date,
      est_delivery: @pickup_date + 1.days,
      est_pickup_by: @pickup_date
    )

    if @order.valid?
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
          pickup_date: new_order_params[:pickup_date],
          pickup_time: new_order_params[:pickup_time],
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

  # api_v1_users_dashboards_new_order_flow_scheduled_pickups_path
  # /api/v1/users/dashboards/new_order_flow/scheduled_pickups
  def create
    @address = @current_user.address
    @region = @address.region
    @order = build_with_charge
    @order.skip_charge_validate = true

    @pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{new_order_params[:pickup_date]},#{new_order_params[:pickup_time]}")

    @order.assign_attributes(
      accept_by: @pickup_date,
      est_delivery: @pickup_date + 1.days,
      est_pickup_by: @pickup_date
    )

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

  private

  def debug_undo
    if NewOrder.all.any?
      NewOrder.last.destroy
    end
  end
  def new_order_params
    params.require(:new_order).permit(%i[
      pickup_type
      detergent
      softener
      bag_count
      tip
      pickup_date
      pickup_time
    ])
  end

end