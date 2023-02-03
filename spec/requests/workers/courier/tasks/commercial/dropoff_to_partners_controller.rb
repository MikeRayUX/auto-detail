require 'rails_helper'

RSpec.describe 'workers/courier/tasks/commercial/dropoff_to_partners_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @worker = Worker.create!(attributes_for(:worker).merge(region_id: @region.id))
    sign_in @worker

    @partner_location = create(:partner_location)

    @client = create(:client)
    @address = @client.addresses.create!(attributes_for(:address))

    @pickup = @address.commercial_pickups.create!(
      reference_code: CommercialPickup.new_reference_code,
      pick_up_date: Date.current.strftime,
      pick_up_window: @client.pickup_window,
      full_address: @address.full_address,
      pick_up_directions: @address.pick_up_directions,
      client_id: @address.id,
      client_price_per_pound: @client.price_per_pound,
      routable_address: @address.address,
      detergent: 'hypoallergenic',
      softener: 'hypo_allergenic'
    )

    @label_code = "#{SecureRandom.hex(3)}".upcase
    @bags_collected = rand(5)

    @pickup.save_new_label(@label_code, @bags_collected )
    @pickup.mark_picked_up
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker views the dropoff to partner step' do
    get workers_courier_tasks_commercial_dropoff_to_partners_path, params: {
      id: @pickup.id
      } 

    page = response.body

    expect(page).to include("Dropoff To Washer")
    expect(page).to include("#{@label_code} (#{@bags_collected} bags)")
    expect(page).to include(@pickup.readable_detergent)
    expect(page).to include(@pickup.readable_softener)
    expect(page).to include("Locate Bags (#{@bags_collected} bags)")
  end

  scenario 'worker selects a dropoff location and the pickup is assigned to a partner location' do
    put workers_courier_tasks_commercial_dropoff_to_partners_path, params: {
      id: @pickup.id,
      partner_location_id: @partner_location.id
    }

    expect(response).to redirect_to workers_dashboards_waiting_orders_path
    expect(flash[:notice]).to eq 'Dropped off successfully!'

    # commercial_pickup
    @pickup.reload

    expect(@pickup.partner_location_id).to eq @partner_location.id
    expect(@pickup.global_status).to eq 'processing'
    expect(@pickup.dropped_off_to_partner_at).to be_present

  end

  scenario 'worker does not select a partner location and is kicked back' do
    put workers_courier_tasks_commercial_dropoff_to_partners_path, params: {
      id: @pickup.id,
      partner_location_id: nil
    }

    expect(response).to redirect_to workers_courier_tasks_commercial_dropoff_to_partners_path(id: @pickup.id)
    expect(flash[:notice]).to eq 'You must select a valid partner to continue'

    # commercial_pickup
    @pickup.reload

    expect(@pickup.partner_location_id).to eq nil
    expect(@pickup.global_status).to eq 'picked_up'
    expect(@pickup.dropped_off_to_partner_at).to eq nil
  end

end