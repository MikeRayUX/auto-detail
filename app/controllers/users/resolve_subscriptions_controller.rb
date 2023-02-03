class Users::ResolveSubscriptionsController < OrderableController
  # skip_before_action :has_active_subscription?
  # skip_before_action :ensure_no_in_progress_orders

  protect_from_forgery with: :exception
  layout 'users/dashboards/new_order_flow/order_layout'

  # GET
  # /users/resolve_subscriptions
  # users_resolve_subscriptions_path
  def index
    if current_user.has_active_subscription?
      redirect_to new_users_dashboards_new_order_flow_pickups_path
    else
      redirect_to new_users_resolve_subscription_path
    end
  end

  # GET
  # new_users_resolve_subscription_path
  def new
    @region = current_user.address.region
    @subscription = Subscription.first
    @tax = @subscription.tax(@region.tax_rate)
    @grandtotal = @subscription.grandtotal(@region.tax_rate)
    @next_renew_date = 1.month.from_now.strftime('%m/%d/%Y')
  end

  # POST
  # new_users_resolve_subscription_path
  def create
    @sub = Subscription.first

    if params.has_key?(:card)
      if current_user.stripe_customer_id
        current_user.update_stripe_payment_method(card_params)
      else
        current_user.create_stripe_customer!(card_params)
      end
    end

    if !current_user.has_active_subscription?
      current_user.activate_subscription!(@sub)
      # current_user.send_subscription_email!
      redirect_to users_resolve_subscription_path(id: 1)
    else
      redirect_to new_users_resolve_subscription_path, flash: {
        notice: 'You already have an active subscription.'
      }
    end

    rescue Stripe::StripeError => e
      p e
      redirect_to new_users_resolve_subscription_path, flash: {
        notice: 'There was a problem processing your payment. Please try again later.'
      }
  end

  # GET
  # /users/resolve_subscriptions/:id
  # users_resolve_subscription_path
  def show
    @next_renew_date = current_user.next_subscription_renewell_date
  end

  private
  def card_params
    params.require(:card).permit(
      :card_brand,
      :card_exp_month,
      :card_exp_year,
      :card_last4,
      :stripe_token
    )
  end
end