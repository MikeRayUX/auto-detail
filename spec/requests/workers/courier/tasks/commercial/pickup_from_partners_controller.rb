require 'rails_helper'

RSpec.describe 'workers/courier/tasks/commercial/pickup_from_partners_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @partner_location = PartnerLocation.create!(attributes_for(:partner_location))

    @worker = Worker.create!(attributes_for(:worker).merge(region_id: @region.id))
    sign_in @worker

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
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker views the pickup from partner task step' do
    get workers_courier_tasks_commercial_pickup_from_partners_path, params: {
      id: @pickup.id
    }

    page = response.body

    expect(page).to include "Pickup From Washer"
    expect(page).to include @pickup.bags_code
    expect(page).to include "(about #{@pickup.bags_collected} bags"
    expect(page).to include @partner_location.business_name.upcase
    expect(page).to include @partner_location.full_address.upcase
    expect(page).to include 'Enter Weights (ex: 12.45)'
  end

  scenario 'worker enters valid weight and new bag count and the orders partner weight is stored as well as the order is marked as picked up from partner' do
    @weight = rand(10.1...100).round(2)
    
    put workers_courier_tasks_commercial_pickup_from_partners_path, params: {
        id: @pickup.id,
        weight: @weight,
        bags_collected: @new_bags_count
    }

    @pickup.reload

    expect(response).to redirect_to workers_dashboards_processing_orders_path

    # order
    expect(@pickup.weight).to eq @weight.to_d
    expect(@pickup.picked_up_from_partner_at.today?).to eq true
    
    expect(@pickup.bags_collected).to eq @new_bags_count
  end

  scenario 'worker does not enter a valid weight or any weight at all and is kicked back' do
    put workers_courier_tasks_commercial_pickup_from_partners_path, params: {
        id: @pickup.id,
        weight: nil
    }

    expect(response).to redirect_to workers_courier_tasks_commercial_pickup_from_partners_path(id: @pickup.id)
    expect(flash[:notice]).to eq 'You must enter a valid weight to continue.'

    put workers_courier_tasks_commercial_pickup_from_partners_path, params: {
        id: @pickup.id,
        weight: 'nil'
    }

    expect(response).to redirect_to workers_courier_tasks_commercial_pickup_from_partners_path(id: @pickup.id)
    expect(flash[:notice]).to eq 'You must enter a valid weight to continue.'
  end

end