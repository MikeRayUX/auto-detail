class Api::V1::Washers::Support::EarningsController < Api::V1::Washers::AuthsController
  
  # GET
  # /api/v1/washers/support/earnings
  # api_v1_washers_support_earnings_path
  def index
    @offers = @current_washer.new_orders.where.not(stripe_transfer_id: nil).or(@current_washer.new_orders.where.not(stripe_transfer_error: nil))

    if @offers.any?
      @returned_offers = []

      @offers.each do |o|
        @returned_offers.push({
          ref_code: o.ref_code,
          payout_desc: o.payout_desc,
          readable_delivered_at: o.readable_delivered_at,
          stripe_transfer_id: o.stripe_transfer_id,
          stripe_transfer_error: o.stripe_transfer_error
        })
      end

      render json: {
        code: 200,
        message: 'offers_returned',
        offers: @returned_offers,
        lifetime_earnings: @current_washer.summed_earnings(@offers)
      }
    else
      render json: {
        code: 200,
        message: 'no_completed_offers'
      }
    end
  end

  private
end