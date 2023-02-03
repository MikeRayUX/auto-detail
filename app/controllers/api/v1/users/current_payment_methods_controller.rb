class Api::V1::Users::CurrentPaymentMethodsController < ApiController
  # after_action :debug_undo, only: %i[update]

  # api_v1_users_current_payment_methods_path
  # /api/v1/users/current_payment_methods
  def show
    if @current_user.stripe_customer_id
      render json: {
        code: 200,
        message: 'payment_method_returned',
        payment_method: @current_user.readable_payment_method
      }
    else
      render json: {
        code: 200,
        message: 'requires_payment_method'
      }
    end
  end

  # api_v1_users_current_payment_methods_path
  # /api/v1/users/current_payment_methods
  def update
    if @current_user.has_payment_method?
      @current_user.update_stripe_payment_method(card_params)
    else
      @current_user.create_stripe_customer!(card_params)
    end

    render json: {
      code: 204,
      message: 'payment_method_saved',
      payment_method: @current_user.readable_payment_method
    }

  rescue Stripe::StripeError => e
    render json: {
      code: 3000,
      message: 'stripe_error',
      errors: e.message
    }
  end

  private

  def debug_undo
    @current_user.update(
      stripe_customer_id: nil,
      card_brand: nil,
      card_last4: nil,
      card_exp_month: nil,
      card_exp_year: nil,
    )
  end

  def card_params
    params.require(:card).permit(%i[
      stripe_token
      card_brand
      card_exp_month
      card_exp_year
      card_last4
    ])
  end

end