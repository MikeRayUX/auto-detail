class Api::V1::Washers::Activations::DirectDepositsController < Api::V1::Washers::AuthsController

  # new_api_v1_washers_activations_direct_deposit_path
  # GET /api/v1/washers/activations/direct_deposits/new 
  def new
    if @current_washer.no_stripe_account?
      @current_washer.create_stripe_account!
    end

    if @current_washer.requires_stripe_setup?
      render json: {
        code: 200,
        message: 'setup_not_completed',
        url: @current_washer.new_stripe_setup_link
      }
    else
      render json: {
        code: 200,
        message: 'setup_already_completed',
        errors: 'This section has already been completed'
      }
    end

  rescue Stripe::StripeError => e
    render json: {
      code: 3000,
      message: 'stripe_error',
      errors: 'Something went wrong. Please try again later.'
    }

    # refresh_url
    # The URL that the user will be redirected to if the account link is no longer valid. Your refresh_url should trigger a method on your server to create a new account link using this API, with the same parameters, and redirect the user to the new account link.

    # return_url
    # REQUIRED
    # The URL that the user will be redirected to upon leaving or completing the linked flow.
  end
end