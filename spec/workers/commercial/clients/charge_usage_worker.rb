require 'rails_helper'
RSpec.describe Commercial::Clients::ChargeUsageWorker, type: :worker do

  before do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @client = create(:client)

    @address_count = rand(1...100)
    @address_count.times do
      @client.addresses.create!(
        street_address: Faker::Address.street_address,
        city: Faker::Address.city,
        state: 'wa',
        zipcode: '98168',
        region_id: @region.id
      )
    end

    @client.addresses.each do |address|
      address.create_pickup_for_today!
    end

    @client.commercial_pickups.each do |pickup|
      pickup.record_partner_weight(rand(12.34...40.56))
      pickup.mark_delivered_to_client('front_door')
      pickup.save_charge

      # p '******************'
      # p pickup.subtotal.to_f
      # p pickup.tax.to_f
      # p pickup.grandtotal.to_f
      # p '******************'
    end
    
    @client.reload

    @worker = Commercial::Clients::ChargeUsageWorker
    Sidekiq::Testing.inline!
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker is added to jobs array' do
    Sidekiq::Testing.fake!
    @worker.perform_async

    expect(@worker.jobs.size).to eq 1
  end

  scenario 'a single commercial pickup is billed successfully' do
    @client.create_stripe_customer!(
      ActionController::Parameters.new({
        stripe_token: 'tok_visa',
        card_brand: @client.card_brand,
        card_exp_month: @client.card_exp_month,
        card_exp_year: @client.card_exp_year,
        card_last4: @client.card_last4
      })
    )

    p '******************'
    p "TOTAL: #{CommercialPickup.count} ORDERS"
    p "TOTAL: #{@client.current_usage} LBS AT #{@client.readable_price_per_pound} "
    p "attempting to charge #{@client.commercial_pickups.delivered.unpaid.count} orders for #{@client.readable_current_charge}"
    p '******************'

    @billable_pickups = @client.commercial_pickups.delivered.unpaid
    
    @start_date = @billable_pickups.first.pick_up_date
    @end_date = @billable_pickups.last.pick_up_date

    @current_usage = @client.current_usage

    @subtotal = @billable_pickups.sum(:subtotal)
    @tax = @billable_pickups.sum(:tax)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    @worker.perform_async(@client.id)

    # transaction
    @t = @client.transactions.first

    expect(@client.transactions.count).to eq 1
    expect(@t.stripe_customer_id).to eq @client.stripe_customer_id
    expect(@t.card_brand).to eq @client.card_brand
    expect(@t.card_exp_month).to eq @client.card_exp_month
    expect(@t.card_exp_year).to eq @client.card_exp_year
    expect(@t.card_last4).to eq @client.card_last4
    expect(@t.customer_email).to eq @client.email
    expect(@t.region_name).to eq 'n/a'
    expect(@t.tax_rate).to eq 0.0
    expect(@t.weight).to eq @current_usage
    expect(@t.price_per_pound).to eq @client.price_per_pound
    expect(@t.subtotal).to eq @subtotal
    expect(@t.tax).to eq @tax
    expect(@t.grandtotal).to eq @grandtotal
    expect(@t.paid).to eq 'paid'
    expect(@t.stripe_response).to eq 'success'
    expect(@t.stripe_charge_id).to be_present
    expect(@t.start_date).to eq @start_date
    expect(@t.end_date).to eq @end_date

    p "weight: #{@t.weight.to_f}"
    p "price /lb: #{@t.price_per_pound.to_f}"
    p "subtotal: #{@t.subtotal.to_f}"
    p "tax: #{@t.tax.to_f}"
    p "tax rate: #{@t.tax_rate}"
    p "grandtotal: #{@t.grandtotal}"

    # commercial pickups
    @client.commercial_pickups.all.each do |pickup|
      expect(pickup.paid).to eq true
    end
    
    @billable_pickups.reload
    @billable_pickups.all.each do |pickup|
      expect(pickup.paid).to eq true
    end

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

  scenario 'a single commercial pickup is billed successfully' do
    p '******************'
    p "TOTAL: #{CommercialPickup.count} ORDERS"
    p "TOTAL: #{@client.current_usage} LBS AT #{@client.readable_price_per_pound} "
    p "attempting to charge #{@client.commercial_pickups.delivered.unpaid.count} orders for #{@client.readable_current_charge}"
    p '******************'

    @billable_pickups = @client.commercial_pickups.delivered.unpaid
    
    @start_date = @billable_pickups.first.pick_up_date
    @end_date = @billable_pickups.last.pick_up_date

    @current_usage = @client.current_usage

    @subtotal = @billable_pickups.sum(:subtotal)
    @tax = @billable_pickups.sum(:tax)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    @worker.perform_async(@client.id)

    # transaction
    @t = @client.transactions.first

    expect(@client.transactions.count).to eq 1
    expect(@t.stripe_customer_id).to eq @client.stripe_customer_id
    expect(@t.card_brand).to eq @client.card_brand
    expect(@t.card_exp_month).to eq @client.card_exp_month
    expect(@t.card_exp_year).to eq @client.card_exp_year
    expect(@t.card_last4).to eq @client.card_last4
    expect(@t.customer_email).to eq @client.email
    expect(@t.region_name).to eq 'n/a'
    expect(@t.tax_rate).to eq 0.0
    expect(@t.weight).to eq @current_usage
    expect(@t.price_per_pound).to eq @client.price_per_pound
    expect(@t.subtotal).to eq @subtotal
    expect(@t.tax).to eq @tax
    expect(@t.grandtotal).to eq @grandtotal
    expect(@t.paid).to eq 'failed'
    expect(@t.stripe_response).to be_present
    expect(@t.stripe_charge_id).to eq 'charge failed'
    expect(@t.start_date).to eq @start_date
    expect(@t.end_date).to eq @end_date

    p "weight: #{@t.weight.to_f}"
    p "price /lb: #{@t.price_per_pound.to_f}"
    p "subtotal: #{@t.subtotal.to_f}"
    p "tax: #{@t.tax.to_f}"
    p "tax rate: #{@t.tax_rate}"
    p "grandtotal: #{@t.grandtotal}"

    # commercial pickups
    @client.commercial_pickups.all.each do |pickup|
      expect(pickup.paid).to eq false
    end
    
    @billable_pickups.reload
    @billable_pickups.all.each do |pickup|
      expect(pickup.paid).to eq false
    end

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

  # scenario 'payment failed and a payment failed email is sent' do
  #   p '******************'
  #   p "TOTAL: #{CommercialPickup.count} ORDERS"
  #   p "TOTAL: #{@client.current_usage} LBS AT #{@client.readable_price_per_pound} "
  #   p "attempting to bill #{@client.commercial_pickups.delivered.unpaid.count} orders for #{@client.readable_current_charge}"
  #   p '******************'

  #   @billable_pickups = @client.commercial_pickups.delivered.unpaid
  #   @start_date = @billable_pickups.first.pick_up_date
  #   @end_date = @billable_pickups.last.pick_up_date

  #   @current_usage = @billable_pickups.sum(:weight)
  #   @subtotal = get_subtotal(@current_usage, @client)
  #   @tax = get_tax(@subtotal, @client)
  #   @grandtotal = get_grandtotal(@subtotal, @tax)

  #   @worker.perform_async(@client.id)

  #   # transaction
  #   @t = @client.transactions.first

  #   expect(@client.transactions.count).to eq 1
  #   expect(@t.stripe_customer_id).to eq @client.stripe_customer_id
  #   expect(@t.card_brand).to eq @client.card_brand
  #   expect(@t.card_exp_month).to eq @client.card_exp_month
  #   expect(@t.card_exp_year).to eq @client.card_exp_year
  #   expect(@t.card_last4).to eq @client.card_last4
  #   expect(@t.customer_email).to eq @client.email
  #   expect(@t.region_name).to eq @client.region_name
  #   expect(@t.tax_rate).to eq @client.tax_rate
  #   expect(@t.weight).to eq @current_usage
  #   expect(@t.price_per_pound).to eq @client.price_per_pound
  #   expect(@t.subtotal).to eq @subtotal
  #   expect(@t.tax).to eq @tax
  #   expect(@t.grandtotal).to eq @grandtotal
  #   expect(@t.paid).to eq 'failed'
  #   expect(@t.stripe_response).to be_present
  #   expect(@t.stripe_charge_id).to eq 'charge failed'
  #   expect(@t.start_date).to eq @start_date
  #   expect(@t.end_date).to eq @end_date

  #   p "weight: #{@t.weight.to_f}"
  #   p "price /lb: #{@t.price_per_pound.to_f}"
  #   p "subtotal: #{@t.subtotal.to_f}"
  #   p "tax: #{@t.tax.to_f}"
  #   p "tax rate: #{@t.tax_rate}"
  #   p "grandtotal: #{@t.grandtotal}"

  #   # commercial pickups
  #   @client.commercial_pickups.all.each do |pickup|
  #     expect(pickup.paid).to eq false
  #   end

  #   # email
  #   expect(ActionMailer::Base.deliveries.count).to eq 1
  # end
 
end

