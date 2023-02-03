class Api::V1::Washers::WorkFlows::CurrentWork::StartOffersController < Api::V1::Washers::AuthsController
  before_action :washer_activated?
  before_action :offer_exists?
  before_action :too_early?, only: %i[update]
  before_action :too_late?, only: %i[update]
  before_action :not_cancelled?, only: %i[show update]

  # GET
  # api_v1_washers_work_flows_current_work_start_offers_path
  # /api/v1/washers/work_flows/current_work/start_offers
  # resume_offers
  def show
    render json: {
      code: 200,
      pickup_type: @offer.pickup_type,
      message: 'status_returned',
      status: @offer.status
    }
  end

  # PUT
  # /api/v1/washers/work_flows/current_work/start_offers
  # api_v1_washers_work_flows_current_work_start_offers_path
  # start offer
  def update
    @offer.user.send_sms_notification!(
      'enroute_to_customer_for_pickup',
      @offer,
      "#{@current_washer.abbrev_name.titleize} is on their way to you for your laundry pickup. Please ensure that your bags are accessible for a contactless pickup. Thanks!"
    )
    @offer.mark_enroute_for_pickup
    render json: {
      code: 200,
      message: 'pickup_started',
      status: @offer.status
    }
  end

  private
  def current_location_params
    params.require(:current_location).permit(%i[lat lng])
  end

  def offer_params
    params.require(:offer).permit(%i[ref_code])
  end


  def washer_activated?
    unless @current_washer.activated?
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end

  def offer_exists?
    @offer = @current_washer.new_orders.find_by(ref_code: offer_params[:ref_code])
    unless @offer
      render json: {
        code: 3000,
        message: 'offer_not_found',
        errors: 'Offer not found.'
      }
    end
  end

  def too_early?
    if @offer.pickup_type == 'scheduled' &&
      DateTime.current < (@offer.est_pickup_by - NewOrder::START_LIMIT)
      render json: {
        code: 3000,
        message: 'too_early',
        errors: 'It is too early to start this pickup.'
      }
    end
  end

  def too_late?
    if @offer.pickup_type == 'scheduled' &&
      DateTime.current > @offer.est_pickup_by 
      render json: {
        code: 3000,
        message: 'too_late',
        errors: 'It is too late to start this pickup.'
      }
    end
  end

  def not_cancelled?
    unless @offer.status != 'cancelled'
      render json: {
        code: 3000,
        message: 'order_cancelled',
        errors: "We're sorry, this offer was cancelled by the customer."
      }
    end
  end
end