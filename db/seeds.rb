require 'factory_bot'

@sendgrid_email = FactoryBot.create(:sendgrid_email)

# frozen_string_literal: true
@region = Region.create!(
	area: 'seattle',
  tax_rate: 0.101,
  washer_capacity: 100,
  price_per_bag: 25,
  washer_pay_percentage: 0.80,
  stripe_tax_rate_id: 'txr_1IAOYwIhRzEonUQKFpEY5pAK',
  max_concurrent_offers: 5,
  failed_pickup_fee: 7,
  business_open: "9:00AM",
  business_close: "8:00PM"
)

5.times do
  WaitList.create(
    email: Faker::Internet.email,
    zipcode: '98168'
  )
end

# @subscription = Subscription.create!(
#   name: 'Tumble Subscription',
#   stripe_product_id: 'prod_IlwZ2R7eYeCrIj',
#   stripe_price_id: 'price_1IAOfwIhRzEonUQKOm1pEOt3',
#   price: 9.99
# )

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
  load seed
end

CoverageArea.all.each do |a|
	a.update_attribute :region_id, @region.id
end

WorkerAccountCreationCode.create!(code: '1234567')

RegionPricing.create!(
  region: 'seattle',
  price_per_pound: 1.99,
  tax_rate: 0.101,
  minimum_charge: 25
)

@landing_banner = SiteBanner.create!(
  display_location: 'landing',
  body_text: 'We are open and performing contactless pickups & deliveries',
  link_text: 'Start A Pickup',
  link_url: 'users_resolve_setups_path',
  alt_url: 'signup_path',
  conditional: 'if user logged in link url, else alt url'
)

@user = User.create!(
  full_name: 'Mike Arriaga',
  email: 'arriaga562@gmail.com',
  password: 'password',
  password_confirmation: 'password',
  # test phone number doesn't incur charges
  phone: '4055555555'
)

@address = @user.create_address!(
  FactoryBot.attributes_for(:address).merge(
    region_id: @region.id
  )
)
@address.geocode
@address.save

@order = @user.orders.create!(
  FactoryBot.attributes_for(:order).merge(
    pick_up_date: Date.today.strftime,
    pick_up_time: DateTime.parse(rand(1..59).minutes.from_now.to_s).strftime('%I:%M%p'),
    full_address: @address.full_address,
    routable_address: @address.address
))

@executive = Executive.create!(
  email: 'info@freshandtumble.com',
  password: 'y22Df22!&9Y3hV8BIK0lbEH17LNGSyVHXL4Dudy',
  password_confirmation: 'y22Df22!&9Y3hV8BIK0lbEH17LNGSyVHXL4Dudy',
)

@worker = @region.workers.create!(
  full_name: 'john doe',
  email: 'worker1@freshandtumble.com',
  phone: '4055555555',
  password: 'workinformyself',
  password_confirmation: 'workinformyself'
)

# partner location
@partner = PartnerLocation.create!(
  street_address: '400 broad st',
  city: 'seattle',
  state: 'wa',
  zipcode: '98109',
  business_name: 'space needle',
  business_phone: '5627872684'
)

# commercial client
@client = Client.create!(
  name: 'acme salon',
  contact_person: 'mike smith',
  email: 'acmesalon@sample.com',
  special_notes: 'salon hours 10am-11pm',
  area_of_business: 'salon',
  pickup_window: 'morning',
  price_per_pound: 1.99,
  phone: '3213213213',
  monday: true,
  tuesday: true,
  wednesday: true,
  thursday: true,
  friday: true,
  saturday: true,
  sunday: true,
  card_brand: 'visa',
  card_exp_month: '6',
  card_exp_year: '2022',
  card_last4: '4242'
)

@client_address = @client.addresses.create!(
  street_address: '1233 s 117th st',
  city: 'seattle',
  state: 'wa',
	zipcode: 98168,
  region_id: @region.id,
  pick_up_directions: 'around back to the left'
)

5.times do
  @client.addresses.create!(
    street_address: Faker::Address.street_address,
    city: 'seattle',
    state: 'wa',
    zipcode: 98168,
    region_id: @region.id,
    pick_up_directions: 'around back to the left'
  )
end

@client_stripe_customer = Stripe::Customer.create(
  source: 'tok_visa',
  email: @client.email
)

@client.update_attributes(
  stripe_customer_id: @client_stripe_customer.id,
)

# WASHER PAYOUTABLE (STRIPE SETUP)
@washer = Washer.new(FactoryBot.attributes_for(:washer, :payoutable).merge(
  region_id: @region.id,
  live_within_region: true,
  min_age: true,
  legal_to_work: true,
  has_equipment: true,
  valid_drivers_license: true,
  valid_car_insurance_coverage: true,
  reliable_transportation: true,
  valid_ssn: true,
  consent_to_background_check: true,
  can_lift_30_lbs: true,
  has_disability: false
  
  ))
@washer.skip_finalized_washer_attributes = true
@washer.save
@washer.create_address!(FactoryBot.attributes_for(:address))

# WASHER ACTIVATED BUT NO STRIPE SETUP
# @washer = Washer.create!(FactoryBot.attributes_for(:washer, :activated).merge(region_id: @region.id))
# @washer.create_address!(FactoryBot.attributes_for(:address))

# new pickup
@commercial_pickup = @client.commercial_pickups.create!(
  address_id: @client_address.id,
  reference_code: CommercialPickup.new_reference_code,
  pick_up_date: Date.today.strftime,
  pick_up_window: @client.pickup_window,
  full_address: @client_address.full_address,
  routable_address: @client_address.address,
  pick_up_directions: @client_address.pick_up_directions,
  detergent: 'hypoallergenic',
  softener: 'hypo_allergenic',
  client_price_per_pound: @client.price_per_pound
)

# completed pickups (billable)
@client.addresses.each do |address| 
  weight = rand(12.34...40.56).round(2)
  @pickup = address.create_pickup_for_today!
  @pickup.record_partner_weight(weight)
  @pickup.mark_delivered_to_client('front_door')
  @pickup.save_charge
end

# new_orders in different statuses
# @user.reload

# @bag_count = rand(1..6)
# @price_per_bag = format('%.2f', @region.price_per_bag)
# @subtotal = NewOrder.calc_subtotal(@bag_count, @region.price_per_bag)
# @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
# @tip = NewOrder::TIP_OPTIONS.sample
# @grandtotal = NewOrder.calc_grandtotal(@subtotal, @tax, @tip)
# @washer_ppb = NewOrder.calc_washer_ppb(@subtotal, @region.washer_pay_percentage, @bag_count)
# @washer_pay = NewOrder.calc_washer_pay(@subtotal, @region.washer_pay_percentage)
# @washer_final_pay = NewOrder.calc_washer_final_pay(@subtotal, @region.washer_pay_percentage, @tip)
# @profit = NewOrder.calc_profit(@subtotal, @washer_pay)

# @codes_params = []
# @bag_count.times do
#   @codes_params.push(SecureRandom.hex(2).upcase)
# end

# if @tip > 0
#   @payout_desc = "$#{NewOrder.readable_decimal(@washer_final_pay)} includes $#{NewOrder.readable_decimal(@tip)} tip"
# else
#   @payout_desc = "$#{NewOrder.readable_decimal(@washer_final_pay)}"
# end

# @created = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))

# @enroute_for_pickup = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @enroute_for_pickup.mark_enroute_for_pickup

# @arrived_for_pickup = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @arrived_for_pickup.mark_enroute_for_pickup
# @arrived_for_pickup.mark_arrived_for_pickup

# @picked_up = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @picked_up.mark_enroute_for_pickup
# @picked_up.mark_arrived_for_pickup
# @picked_up.mark_picked_up(JSON.parse(@codes_params.to_json))

# @completed = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @completed.mark_enroute_for_pickup
# @completed.mark_arrived_for_pickup
# @completed.mark_picked_up(JSON.parse(@codes_params.to_json))
# @completed.mark_completed

# @delivered = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @delivered.mark_enroute_for_pickup
# @delivered.mark_arrived_for_pickup
# @delivered.mark_picked_up(JSON.parse(@codes_params.to_json))
# @delivered.mark_completed
# @delivered.mark_delivered


# @cancelled = @user.new_orders.create!(
#   FactoryBot.attributes_for(:new_order, :open_offer).merge(
#     ref_code: SecureRandom.hex(5),
#     pickup_type: 'asap',
#     washer_id: @washer.id,
#     est_pickup_by: NewOrder.gen_pickup_estimate,
#     bag_count: @bag_count,
#     bag_price: @region.price_per_bag,
#     subtotal: @subtotal,
#     tax: @tax,
#     tip: @tip,
#     washer_ppb: @washer_ppb,
#     washer_final_pay: @washer_final_pay,
#     payout_desc: @payout_desc,
#     grandtotal: @grandtotal,
#     profit: @profit,
#     tax_rate: @region.tax_rate,
#     washer_pay: @washer_pay,
#     region_id: @user.address.region.id,
#     address: @address.address,
#     zipcode: @address.zipcode,
#     unit_number: @address.unit_number,
#     directions: @address.pick_up_directions,
#     full_address: @address.full_address,
#     address_lat: @address.latitude,
#     address_lng: @address.longitude
# ))
# @cancelled.mark_enroute_for_pickup
# @cancelled.mark_arrived_for_pickup
# @cancelled.update(
#   cancelled_at: DateTime.current, 
#     status: 'cancelled',
# )



