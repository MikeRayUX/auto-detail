class Api::V1::Washers::WorkFlows::CurrentWork::CurrentOffersController < Api::V1::Washers::AuthsController
  before_action :washer_activated?
  include Formattable

  # # GET
  # /api/v1/washers/work_flows/current_work/current_offers
  # api_v1_washers_work_flows_current_work_current_offers_path
  # gets washers current work
  def index
    @offers = @current_washer.new_orders.in_progress
    
    if @offers.any?
      @sorted = @offers.order(created_at: :desc)
      @current_offers = []

      @sorted.each do |o|
        @user = o.user

        @current_offers.push({
          ref_code: o.ref_code,
          status: o.status,
          bags_to_scan: o.bag_count,
          bag_codes: o.bag_codes,
          pay: o.readable_washer_pay,
          failed_pickup_fee: readable_decimal(o.failed_pickup_fee),
          detergent: o.readable_detergent,
          softener: o.readable_softener,
          picked_up_at: o.picked_up_at,
          wash_notes: o.wash_notes,
          return_by: o.est_delivery,
          todo: o.current_todo,
          readable_return_by: "#{o.est_delivery.strftime('%m/%d/%Y (by %I:%M%P)')}".titleize,
          scheduled: o.scheduled_pickup,
          readable_scheduled: o.readable_scheduled,
          customer: {
            full_name: @user.full_name.upcase,
            phone: @user.formatted_phone
          },
          address: {
            address: o.address,
            directions: o.directions,
            full_address: o.full_address.upcase,
            unit_number: o.unit_number,
            lat: o.address_lat,
            lng: o.address_lng
          }
        })
      end

      render json: {
        code: 200,
        message: 'offers_returned',
        current_offers: @current_offers
      }
    else
      render json: {
        code: 200,
        message: 'no_current_offers'
      }
    end
  end

  private
  def washer_activated?
    unless @current_washer.activated?
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end
end