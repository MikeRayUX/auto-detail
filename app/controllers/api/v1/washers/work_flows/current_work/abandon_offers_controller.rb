class Api::V1::Washers::WorkFlows::CurrentWork::AbandonOffersController < Api::V1::Washers::AuthsController
  before_action :washer_activated?
  before_action :offer_exists?
  before_action :is_scheduled?
  before_action :not_cancelled?

  # PUT
  # /api/v1/washers/work_flows/current_work/abandon_offers
  # api_v1_washers_work_flows_current_work_abandon_offers_path
  # abandon offer
  def update
    @current_washer.abandon_offer(@offer)

    if abandoned_early?
      @minutes = ((@offer.est_pickup_by - DateTime.current.to_time) / 60).to_i
      @feedback = "(#{@minutes} MINUTES EARLY)"
    else
      @minutes = ((DateTime.current.to_time - (@offer.est_pickup_by - NewOrder::ABANDON_LIMIT)) / 60).to_i
      @feedback = "(#{@minutes} MINUTES LATE)"
    end

    OfferEvent.create!(
      washer_id: @current_washer.id,
      new_order_id: @offer.id,
      event_type: 'offer_abandoned',
      feedback: @feedback
    )

    @other_washers = @offer.region.washers.activated.where.not(id: @current_washer.id)

    if @other_washers.any?
      @other_washers.each do |w|
        SmsAlertUntrackedWorker.perform_async(
          w.phone, "There are new Wash Offers Available in The Fresh And Tumble Washer App. Grab one before they're gone!"
        )
      end
    end

    render json: {
      code: 204,
      message: 'offer_abandoned',
      feedback: 'Offer has been cancelled.'
    }
  end

  private
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

  def is_scheduled?
    unless @offer.pickup_type == 'scheduled'
      render json: {
        code: 3000,
        message: 'offer_not_found',
        errors: 'Offer not found.'
      }
    end
  end

  def not_cancelled?
    unless @offer.status != 'cancelled'
      render json: {
        code: 3000,
        message: 'offer_already_cancelled',
        errors: 'This offer has been cancelled by the customer.'
      }
    end
  end

  def abandoned_early?
    @offer.est_pickup_by > NewOrder::ABANDON_LIMIT.from_now
  end

end