class Api::V1::Users::Dashboards::NewOrderFlow::PickupEstimationsController < Api::V1::OrderableController
  # protect_from_forgery with: :exception
  before_action :business_open?
  before_action :washers_available?

  # api_v1_users_dashboards_new_order_flow_pickup_estimations_path
  # /api/v1/users/dashboards/new_order_flow/pickup_estimations
  def index
    @minutes = rand(55..65)
    @estimate = (DateTime.current + @minutes.minutes).strftime('%I:%M%P').upcase

    # removes leading zeros
    if @estimate.first == '0'
      @estimate = @estimate[1...@estimate.length]
    end

    render json: {
      code: 200,
      status: :ok,
      message: 'washers_available',
      pickup_estimate: "#{@estimate}"
    }
  end

  private
  def business_open?
    unless @current_user.region.business_open?
      render json: {
        code: 3000,
        message: 'business_not_open',
        errors: "Asap is not currently available as it is past our normal business hours. You can still schedule a pickup for later or check back during normal business hours (#{@current_user.region.readable_business_hours})"
      }
    end
  end

  def washers_available?
    unless @current_user.region.washer_open_offers_checked_recently?
      render json: {
        code: 3000,
        status: :ok,
        message: 'no_washers_available',
        errors: "We're sorry, ASAP (same day option) is not available in your region yet. Don't worry, You can still schedule a pickup with the 'Later' option"
      }
    end
  end
end