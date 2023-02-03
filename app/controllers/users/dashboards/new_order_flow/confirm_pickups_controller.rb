class Users::Dashboards::NewOrderFlow::ConfirmPickupsController < OrderableController
  include CalculateChargable

  layout 'users/dashboards/new_order_flow/order_layout'

  # /users/dashboards/new_order_flow/confirm_pickups/new
  # new_users_dashboards_new_order_flow_confirm_pickup_path
  def new
    @order = build_order_from_params
    @order.skip_finalization_attributes = true
    @order.skip_charge_validate = true

    @form_date = new_order_params[:pickup_date]
    @form_time = new_order_params[:pickup_time]

    @pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{new_order_params[:pickup_date]},#{new_order_params[:pickup_time]}")

    @order.assign_attributes(
      accept_by: @pickup_date,
      est_delivery: @pickup_date + 1.days,
      est_pickup_by: @pickup_date
    )

    if @order.valid?
      @address = current_user.address
      @region = @address.region

      @subtotal = NewOrder.calc_subtotal(@order.bag_count, @address.region.price_per_bag)
      @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
      @tax_rate = @region.tax_rate_percentage
    else
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
        notice: @order.errors.full_messages.first
      }
    end
  end

  # /users/dashboards/new_order_flow/confirm_pickups
  # users_dashboards_new_order_flow_confirm_pickups_path
  def create
    @address = current_user.address
    @region = @address.region

    @order = build_with_charge

    @pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{new_order_params[:pickup_date]},#{new_order_params[:pickup_time]}")

    @order.assign_attributes(
      accept_by: @pickup_date,
      est_delivery: @pickup_date + 1.days,
      est_pickup_by: @pickup_date
    )

    @order.skip_charge_validate = true

    if @order.valid?
      @order.charge_order!(current_user)
      @order.save!
      @order.send_new_order_email!(@region, current_user, @address)
      @order.alert_washers_in_region!
      redirect_to users_dashboards_new_order_flow_track_pickup_path(id: @order.ref_code)
    else
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
        notice: @order.errors.full_messages.first
      }
    end

    rescue Stripe::StripeError => e
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
       notice: e
      }
  end

  private
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