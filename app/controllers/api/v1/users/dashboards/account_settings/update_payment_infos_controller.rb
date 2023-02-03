class Api::V1::Users::Dashboards::AccountSettings::UpdatePaymentInfosController < ApiController

  # GET
  # api_v1_users_dashboards_account_settings_update_payment_infos_path
  # /api/v1/users/dashboards/account_settings/update_payment_infos
  def show
    if @current_user.has_payment_method?
      render json: {
        code: 200,
        status: 'success',
        message: 'has_payment_method',
        data: {
          payment_method: {
            card_brand: @current_user.card_brand.upcase,
            card_exp_month: @current_user.card_exp_month.upcase,
            card_exp_year: @current_user.card_exp_year.upcase,
            card_last4: @current_user.card_last4.upcase
          }
        }
      }
    else
      render json: {
        code: 200,
        status: 'success',
        message: 'no_payment_method'
      }
    end
  end

  # POST
  # api_v1_users_dashboards_account_settings_update_payment_infos_path
  # /api/v1/users/dashboards/account_settings/update_payment_infos
  def create
    @stripe_customer_id = create_or_update_stripe_customer(@current_user, token_params[:stripe_token])

    if @current_user.update_attributes(card_params.merge(stripe_customer_id: @stripe_customer_id))
      render json: {
        code: 200,
        status: 'success',
        message: 'card_updated'
      }
    else
      render json: {
        code: 3000,
        status: 'failure',
        message: 'card_invalid'
      }
    end

    rescue Stripe::StripeError => e
      render json: {
        code: 3000,
        status: 'failure',
        message: 'stripe_error'
      }
  end

  private
  def card_params
    params.require(:card).permit(:card_brand, :card_exp_month, :card_exp_year, :card_last4)
  end

  def token_params
    params.require(:token).permit(:stripe_token)
  end

  protected

  def create_or_update_stripe_customer(user, token)
    @customer_id = if user.has_payment_method?
      Stripe::Customer.update(
        user.stripe_customer_id,
        source: token
      )
      user.stripe_customer_id
    else
      @customer = Stripe::Customer.create(
        source: token,
        email: user.email
      ).id
    end
    @customer_id
  end

  def create_stripe_customer(token, user)
    @customer = Stripe::Customer.create(
      source: token,
      email: user.email
    )
    @customer.id
  end
end