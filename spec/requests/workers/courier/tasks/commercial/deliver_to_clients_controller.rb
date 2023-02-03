require 'rails_helper'

RSpec.describe 'workers/courier/tasks/commercial/deliver_to_clients_controller', type: :request do

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
    @new_bags_count = rand((@bags_collected + 1)...(@bags_collected + 5))

    @pickup.save_new_label(@label_code, @bags_collected )
    @pickup.mark_picked_up
    @pickup.update_attribute(:partner_location_id, @partner_location.id)
    @pickup.mark_received_by_partner
    @pickup.update_attribute(:bags_collected, @new_bags_count)

    @weight = rand(10.1...100).round(2)
    @pickup.save_weight!(@weight)
    @pickup.mark_picked_up_from_partner
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker views the pickup from partner task step' do
    get workers_courier_tasks_commercial_deliver_to_clients_path, params: {
      id: @pickup.id
    }
    
    page = response.body
    expect(page).to include(@client.name.upcase)
  end

  scenario 'worker submits deliver and the pickup is marked as delivered and delivery location is stored' do
    @delivery_location = CommercialPickup.courier_stated_delivered_locations.to_a.sample.first
    put workers_courier_tasks_commercial_deliver_to_clients_path, params: {
      id: @pickup.id,
      delivery_location: @delivery_location
    }

    expect(response).to redirect_to workers_dashboards_ready_for_deliveries_path
    expect(flash[:notice]).to eq 'Delivery Completed.'
    
    # pickup
    @pickup.reload
    expect(@pickup.courier_stated_delivered_location).to be_present
    expect(@pickup.delivered_to_client_at).to be_present
    expect(@pickup.delivered_to_client_at.today?).to eq true
    expect(@pickup.courier_stated_delivered_location).to eq @delivery_location
  end

end