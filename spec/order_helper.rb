include Users::Orders::Chargeable

def get_random_detergent
  %w[
    tide_original 
    tide_hypoallergenic
    regular_detergent
    hypoallergenic
  ].sample
end

def get_random_softener
  %w[
    bounce 
    snuggle 
    hypo_allergenic 
    no_softener
    regular_softener
  ].sample
end

def get_random_delivery_location
  %w[
    front_door
    back_door
    secure_mailroom
    In a secure location
  ].sample
end

def get_variable_date
  @date = Time.parse(Appointment::POSSIBLE_TIMESLOTS.last) > 45.minutes.from_now ? Date.current.strftime : Date.current.tomorrow.strftime
  
  if Date.parse(@date).strftime('%A') == 'Sunday'
    @date = Date.current.tomorrow.tomorrow.strftime
  else
    @date
  end
end

def get_new_reference_code
  "LB-#{SecureRandom.hex(5)}".upcase
end

def get_new_bags_code
  "FT-#{SecureRandom.hex(5)}".upcase
end

def get_random_weight
  rand(11.34..35.6).round(2)
end

def get_random_pickup_problem
  %w[
    no_residential_access
    cannot_locate_order
  ].sample
end

def get_random_delivery_problem
  %w[
    no_residential_access
    business_closed
  ].sample
end

def create_stripe_customer!
  @customer = Stripe::Customer.create(
    source: 'tok_visa',
    email: @user.email
  )

  @card = @customer.sources.data.first

  @user.update_attributes!(
    stripe_customer_id: @customer.id,
    card_brand: @card[:brand],
    card_exp_month: @card[:exp_month],
    card_exp_year: @card[:exp_year],
    card_last4: @card[:last4]
  )
  # @user.reload

  rescue Stripe::StripeError => e
    p e
end

def retrieve_stripe_customer(user)
  Stripe::Customer.retrieve(user.stripe_customer_id)
end

def mock_charged_order!
  @subtotal = get_subtotal(@order, @pricing)
  @tax = get_tax(@subtotal, @user)
  @grandtotal = get_grandtotal(@subtotal, @tax)

  @transaction = @user.transactions.create!(
    paid: 'paid',
    stripe_charge_id: 'asdfasdfasdf',
    order_id: @order.id,
    order_reference_code: @order.reference_code,
    stripe_customer_id: @user.stripe_customer_id,
    card_brand: @user.card_brand,
    card_exp_month: @user.card_exp_month,
    card_exp_year: @user.card_exp_year,
    card_last4: @user.card_last4,
    customer_email: @user.email,
    price_per_pound: @pricing.price_per_pound,
    weight: @order.courier_weight,  
    subtotal: @subtotal,
    tax: @tax,
    wash_hours_saved: @order.wash_hours_saved,
    grandtotal: @grandtotal,
    tax_rate: @user.tax_rate,
    region_name: @user.region_name
  )

  @transaction.save!
end