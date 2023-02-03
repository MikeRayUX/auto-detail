require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/workflows/current_work/current_offers_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_scheduled_open_offers(rand(5..10))
    @offer = NewOrder.first
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: ''
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'washer is not activated' do
    # before_action :washer_activated?
    @w.deactivate!

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'not_activated'
  end
 

  scenario 'washer has one current in_progress offer and it is returned' do
    @offer = NewOrder.all.sample
    @offer.take_washer(@w)

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    expect(json[:current_offers].length).to eq @w.new_orders.in_progress.length
    expect(json[:current_offers].length).to eq @w.new_orders.length
  end

  scenario 'washer has multiple in_progress_offers and they are all returned' do
    NewOrder.all.each do |o|
      o.take_washer(@w)
    end

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    expect(json[:current_offers].length).to eq @w.new_orders.in_progress.length
    expect(json[:current_offers].length).to eq @w.new_orders.length
    expect(json[:current_offers].length).to eq NewOrder.count
  end

  scenario 'washer picked up the order so its bag codes are returned' do
    @offer = NewOrder.all.sample
    @offer.take_washer(@w)

    @bag_codes = []
    @offer.bag_count.times do
      @bag_codes.push(SecureRandom.hex(2).upcase)
    end

    @saved_codes = @bag_codes.split(',').join('/')

    @offer.mark_picked_up(JSON.parse(@bag_codes.to_json))

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @first_offer = json[:current_offers].first
    
    expect(@first_offer[:ref_code]).to eq @offer.ref_code
    expect(@first_offer[:return_by]).to be_present
    expect(@first_offer[:bags_to_scan]).to eq @offer.bag_count
    expect(@first_offer[:bag_codes]).to eq @saved_codes
    expect(@first_offer[:bag_codes].split('/').count).to eq @offer.bag_count
    expect(@first_offer[:pay]).to eq "$#{format('%.2f', @offer.washer_pay)} + Tips"
    expect(@first_offer[:failed_pickup_fee]).to eq NewOrder.readable_decimal(@offer.failed_pickup_fee)
    expect(@first_offer[:detergent]).to eq @offer.readable_detergent
    expect(@first_offer[:softener]).to eq @offer.readable_softener
    expect(@first_offer[:readable_return_by]).to eq "#{@offer.est_delivery.strftime('%m/%d/%Y (by %I:%M%P)')}".titleize
    # current_step

    @offer.reload
    expect(@first_offer[:status]).to be_present
    expect(@first_offer[:status]).to eq @offer.status
    expect(@first_offer[:status]).to eq 'picked_up'

    # customer
    expect(@first_offer[:customer][:full_name]).to eq @offer.user.full_name.upcase
    expect(@first_offer[:customer][:phone]).to eq @offer.user.formatted_phone
    # address
    expect(@first_offer[:address][:address]).to eq @offer.user.address.address
    expect(@first_offer[:address][:full_address]).to eq @offer.user.address.full_address.upcase
    expect(@first_offer[:address][:unit_number]).to eq @offer.user.address.unit_number
    expect(@first_offer[:address][:lat]).to eq @offer.address_lat
    expect(@first_offer[:address][:lng]).to eq @offer.address_lng
  end
  
  scenario 'washer does not have a current offer so no_current_offer is returned' do
    NewOrder.all.each do |o|
      o.drop_washer
    end

    get '/api/v1/washers/work_flows/current_work/current_offers',
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'no_current_offers'
  end

  # CURRENT_TODO START
  scenario 'asap offer has been accepted but has not been started yet so the Pick Up by todo is returned' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Pick Up #{@current_offer[:bags_to_scan]} Bags (By #{@offer.est_pickup_by.strftime('%I:%M%P)')}"
  end

  scenario 'asap offer is enroute_for_pickup and the same todo is returned for status that are below picked_up_at' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)
    @offer.update(status: 'enroute_for_pickup')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Pick Up #{@current_offer[:bags_to_scan]} Bags (By #{@offer.est_pickup_by.strftime('%I:%M%P)')}"
  end

  scenario 'asap offer is arrived_for_pickup and the same todo is returned for status that are below picked_up_at' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)
    @offer.update(status: 'arrived_for_pickup')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Pick Up #{@current_offer[:bags_to_scan]} Bags (By #{@offer.est_pickup_by.strftime('%I:%M%P)')}"
  end

  scenario 'asap offer is picked up and instruction to wash is returned' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)
    @offer.update(status: 'picked_up')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Wash & Deliver #{@current_offer[:bags_to_scan]} Bags By #{@offer.readable_return_by}"
  end

  scenario 'asap offer wash is completed so deliver by est_delivery' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)
    @offer.update(status: 'completed')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Deliver #{@current_offer[:bags_to_scan]} Bags By #{@offer.readable_return_by}"
  end

  scenario 'offer is delivered so completed is returned' do
    @offer = NewOrder.all.sample
    @offer.update(
      pickup_type: 'asap',
      est_pickup_by: DateTime.current + 10.minutes,
      est_delivery: DateTime.current + 1.days
    )
    
    @offer.take_washer(@w)
    @offer.update(status: 'delivered')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Completed"
  end

  scenario 'scheduled offer has been accepted, but it is not time to Pick Up yet, so Pick Up on x date is returned as the todo, the scheduled Pick Up is also in the future (not today), so the mm/dd/yyyy is returned' do
    @offer = NewOrder.all.sample
   
    @offer.take_washer(@w)

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Scheduled Pick Up #{@offer.est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')}"
  end

  scenario 'scheduled offer is for today so a today Pick Up time is returned instead of mm/dd/yyyy' do
    @offer = NewOrder.all.sample

    @pickup_date = Date.current.strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @scheduled = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @offer.update(
      pickup_type: 'scheduled',
      accept_by: @scheduled,
      est_delivery: @scheduled + 1.days,
      est_pickup_by: @scheduled
    )
    @offer.take_washer(@w)

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Today #{@offer.est_pickup_by.strftime('at %I:%M%P')}"
  end

  scenario 'sheduled offer is enroute for Pick Up but the status still shows the scheduled Pick Up time' do
    @offer = NewOrder.all.sample

    @pickup_date = Date.current.strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @scheduled = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @offer.update(
      pickup_type: 'scheduled',
      accept_by: @scheduled,
      est_delivery: @scheduled + 1.days,
      est_pickup_by: @scheduled,
    )
    @offer.take_washer(@w)

    @offer.update(status: 'enroute_for_pickup')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Today #{@offer.est_pickup_by.strftime('at %I:%M%P')}"
  end

  scenario 'sheduled offer is has arrived for Pick Up but the status still shows the scheduled Pick Up time' do
    @offer = NewOrder.all.sample

    @pickup_date = Date.current.strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @scheduled = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @offer.update(
      pickup_type: 'scheduled',
      accept_by: @scheduled,
      est_delivery: @scheduled + 1.days,
      est_pickup_by: @scheduled,
    )
    @offer.take_washer(@w)

    @offer.update(status: 'arrived_for_pickup')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Today #{@offer.est_pickup_by.strftime('at %I:%M%P')}"
  end

  scenario 'scheduled offer has been picked up, the todo now says wash & deliver' do
    @offer = NewOrder.all.sample

    @pickup_date = Date.current.strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @scheduled = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @offer.update(
      pickup_type: 'scheduled',
      accept_by: @scheduled,
      est_delivery: @scheduled + 1.days,
      est_pickup_by: @scheduled,
    )
    @offer.take_washer(@w)

    @offer.update(status: 'picked_up')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Wash & Deliver #{@current_offer[:bags_to_scan]} Bags By #{@offer.readable_return_by}"
  end

  scenario 'scheduled offer has been completed and now the todo is deliver by' do
    @offer = NewOrder.all.sample

    @pickup_date = Date.current.strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @scheduled = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @offer.update(
      pickup_type: 'scheduled',
      accept_by: @scheduled,
      est_delivery: @scheduled + 1.days,
      est_pickup_by: @scheduled,
    )
    @offer.take_washer(@w)

    @offer.update(status: 'completed')

    get '/api/v1/washers/work_flows/current_work/current_offers', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    @current_offer = json[:current_offers].first

    expect(@current_offer[:todo]).to eq "Deliver #{@current_offer[:bags_to_scan]} Bags By #{@offer.readable_return_by}"
  end
  # CURRENT_TODO END
end