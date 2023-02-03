require 'rails_helper'

RSpec.describe 'workers/courier/tasks/commercial/pickup_from_customer_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @worker = Worker.create!(attributes_for(:worker).merge(region_id: @region.id))

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

    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker views the pickup from customer task step' do
    get workers_courier_tasks_commercial_pickup_from_clients_path, params: {
      id: @pickup.id
    }
    
    page = response.body

    expect(page).to include("Pick Up From Commercial Customer")
    expect(page).to include(@client.name.upcase)
    expect(page).to include(@pickup.formatted_appointment)
    expect(page).to include(@pickup.full_address.upcase)
    expect(page).to include(@pickup.pick_up_directions)
  end

  scenario 'a unique label code is generated' do
    100.times do
      Order.create!(attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address,
        bags_code: SecureRandom.hex(2).upcase
      ))

      @address.commercial_pickups.create!(
        reference_code: CommercialPickup.new_reference_code,
        pick_up_date: Date.current.strftime,
        pick_up_window: @client.pickup_window,
        full_address: @address.full_address,
        pick_up_directions: @address.pick_up_directions,
        client_id: @address.id,
        client_price_per_pound: @client.price_per_pound,
        routable_address: @address.address,
        detergent: 'hypoallergenic',
        softener: 'hypo_allergenic',
        bags_code: SecureRandom.hex(2).upcase
      )
    end

    get workers_courier_tasks_commercial_pickup_from_clients_path, params: {
      id: @pickup.id,
    }
    
    page = response.body

    expect(page).to include("Pick Up From Commercial Customer")
  end

  scenario 'worker collects bags, prints labels, and submits the form with the new qr code' do
    qr_code = "#{SecureRandom.hex(3)}".upcase
    bag_count = rand(1..10)

    put workers_courier_tasks_commercial_pickup_from_clients_path, params: {
      id: @pickup.id,
      qr_code: qr_code,
      bag_count: bag_count
    }
    
    page = response.body

    expect(response).to redirect_to workers_dashboards_open_appointments_path
    expect(flash[:notice]).to eq 'Pickup was successful!'

    # order
    @pickup.reload
    expect(@pickup.bags_code).to eq qr_code
    expect(@pickup.bags_collected).to eq bag_count
  end
end