class Api::V1::Washers::Offers::AcceptOffersController < Api::V1::Washers::AuthsController
  before_action :check_activation_status
  before_action :offer_exists?
  before_action :any_asap_offers_pending_pickup
  before_action :under_max_concurrent_asap_offers

  include Formattable

  # PUT
  # /api/v1/washers/offers/accept_offers
  # api_v1_washers_offers_accept_offers_path
  def update
    @user = @offer.user
    @offer.take_washer(@current_washer)

    @offer.offer_events.create!(
      washer_id: @current_washer.id,
      event_type: 'offer_accepted',
      feedback: nil
    )

    render json: {
      code: 200,
      status: :ok,
      message: 'offer_accepted',
      current_offer: {
        ref_code: @offer.ref_code,
        status: @offer.status,
        bags_to_scan: @offer.bag_count,
        bag_codes: @offer.bag_codes,
        pay: @offer.readable_washer_pay,
        failed_pickup_fee: readable_decimal(@offer.failed_pickup_fee),
        detergent: @offer.readable_detergent,
        softener: @offer.readable_softener,
        wash_notes: @offer.wash_notes,
        todo: @offer.current_todo,
        return_by: @offer.est_delivery,
        readable_return_by: @offer.readable_return_by,
        scheduled: @offer.scheduled_pickup,
        readable_scheduled: @offer.readable_scheduled,
        customer: {
          full_name: @user.full_name.upcase,
          phone: @user.formatted_phone
        },
        address: {
          address: @offer.address,
          directions: @offer.directions,
          full_address: @offer.full_address.upcase,
          unit_number: @offer.unit_number,
          lat: @offer.address_lat,
          lng: @offer.address_lng
        }
      }
    }
  end

  private
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

  def offer_exists?
    @offer = @current_washer.region.new_orders.offerable.find_by(ref_code: offer_params[:ref_code])
    unless @offer
      render json: {
        code: 200,
        status: :ok,
        message: 'already_taken',
        errors: 'This Wash Offer has already been taken.'
      }
    end
  end

  def any_asap_offers_pending_pickup
    if @offer.pickup_type == 'asap'
      unless @current_washer.new_orders.asap_pickups_pending.none?
        render json: {
          code: 3000,
          message: 'asap_offer_already_pending_pickup',
          errors: 'You already have an asap offer that is pending pickup.'
        }
      end
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
end