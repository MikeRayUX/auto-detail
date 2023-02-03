require 'rails_helper'

RSpec.describe 'executives/dashboards/commercial/new_clients_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    
    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @executive = create(:executive)
    sign_in @executive
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'can view the new client form' do
    get new_executives_dashboards_commercial_new_client_path

    page = response.body

    expect(page).to include('New Client Form')
  end

  scenario 'a new client is created with valid data' do
    @address_count = rand(1..9)

    @client_params = {
      name: 'acme salon',
      phone: '5555555555',
      email: 'acmesalon@sample.com',
      special_notes: 'nothing here',
      contact_person: 'adam smith',
      area_of_business: 'nail salon',
      monday: 1,
      tuesday: 1,
      wednesday: 1,
      thursday: 1,
      friday: 1,
      saturday: 1,
      sunday: 1,
      pickup_window: 'afternoon',
      price_per_pound: 1.49,
      pick_up_directions: 'around back',
      address_count: @address_count
    }

    @card_params = {
      card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '2021',
        card_last4: '4242',
        stripe_token: 'tok_visa'
    }

    @addresses = []

    @address_count.times do |num|
      @address = Address.new(
        street_address: Faker::Address.street_address.downcase,
        unit_number: rand(10..50),
        city: Faker::Address.city.downcase,
        state: 'wa',
        zipcode: '98168',
        phone: '',
        pick_up_directions: ''
      )

      @addresses.push(@address)

      @client_params["address_street_address_#{num}"] = 
      @address.street_address
      @client_params["address_unit_number_#{num}"] = @address.unit_number
      @client_params["address_city_#{num}"] = 
      @address.city
      @client_params["address_state_#{num}"] = @address.state
      @client_params["address_zipcode_#{num}"] = @address.zipcode
      @client_params["address_phone_#{num}"] = @address.phone
      @client_params["address_pick_up_directions_#{num}"] = @address.pick_up_directions
    end

    # p @client_params
    post executives_dashboards_commercial_new_clients_path, params: {
      new_client: @client_params,
      card: @card_params
    }

    # client
    @client = Client.first
    expect(@client.name).to eq 'acme salon'
    expect(@client.phone).to eq '5555555555'
    expect(@client.email).to eq 'acmesalon@sample.com'
    expect(@client.special_notes).to eq 'nothing here'
    expect(@client.contact_person).to eq 'adam smith'
    expect(@client.area_of_business).to eq 'nail salon'
    expect(@client.monday).to eq true
    expect(@client.tuesday).to eq true
    expect(@client.wednesday).to eq true
    expect(@client.thursday).to eq true
    expect(@client.friday).to eq true
    expect(@client.saturday).to eq true
    expect(@client.sunday).to eq true
    expect(@client.pickup_window).to eq 'afternoon'
    expect(@client.card_brand).to eq 'visa'
    expect(@client.card_exp_month).to eq '04'
    expect(@client.card_exp_year).to eq '2021'
    expect(@client.card_last4).to eq '4242'
    expect(@client.stripe_customer_id).to be_present
    expect(@client.price_per_pound).to eq 1.49

    expect(@client.addresses.count).to eq @addresses.count
    expect(@client.commercial_pickups.count).to eq 0

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end
end