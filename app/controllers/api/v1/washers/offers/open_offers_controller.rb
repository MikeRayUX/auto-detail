class Api::V1::Washers::Offers::OpenOffersController < Api::V1::Washers::AuthsController
  before_action :check_activation_status
  before_action :no_asap_offers_pending_pickup
  before_action :under_max_concurrent_asap_offers
  before_action :offers_available?
  
  # GET
  # /api/v1/washers/offers/open_offers
  # api_v1_washers_offers_open_offers_path
  def index
    @offers = []
    @offerable_orders.each do |o|
      @offers.push({
        ref_code: o.ref_code,
        bags_to_scan: o.bag_count,
        pay: "$#{o.readable_decimal(o.washer_pay)} + tips",
        return_by: "#{o.est_delivery.strftime('%m/%d/%Y by %I:%M%P')}",
        scheduled: o.scheduled_pickup,
        readable_scheduled: o.readable_scheduled,
        total_seconds: o.total_seconds,
        seconds_to_accept: o.seconds_to_accept,
        percent_left: o.percent_left_to_accept,
        distance: o.miles_away(current_location_params),
        zipcode: o.zipcode
      })
    end
    
    render json: {
      code: 200,
      status: :ok,
      message: 'offers_available',
      offers: @offers
    }
  end

  private
  def current_location_params
    params.require(:current_location).permit(%i[lat lng])
  end

  def offer_params
    params.require(:offer).permit(%i[ref_code])
  end

  def check_activation_status
    unless @current_washer.activated?
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end

  def no_asap_offers_pending_pickup
    unless @current_washer.new_orders.asap_pickups_pending.none?
      render json: {
        code: 3000,
        message: 'offer_already_pending_pickup',
        errors: 'You already have an asap offer that is pending pickup.'
      }
    end
  end

  def under_max_concurrent_asap_offers
    unless @current_washer.under_max_concurrent_asap_offers?
      render json: {
        code: 3000,
        message: 'max_offers_reached',
        errors: 'You have reached your limit for simultaneous offers'
      }
    end
  end

  def offers_available?
    @region = @current_washer.region
    @region.refresh_last_washer_offer_check
    @offerable_orders = @region.new_orders.offerable

    unless @offerable_orders.any?
      render json: {
        code: 200,
        status: :ok,
        message: 'none_available'
      }
    end
  end
end