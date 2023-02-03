require 'rails_helper'
RSpec.describe Commercial::Clients::GenerateDailyStopsWorker, type: :worker do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    Sidekiq::Testing.inline!
    Sidekiq::Worker.clear_all

    @client = create(:client)
    @address = @client.addresses.create!(attributes_for(:address))

    @worker = Commercial::Clients::GenerateDailyStopsWorker
  end

  after do
    Sidekiq::Testing.inline!
    Sidekiq::Worker.clear_all
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker is added to jobs array' do
    Sidekiq::Testing.fake!

    @worker.perform_async

    expect(Sidekiq::Worker.jobs.size).to eq 1
  end

  scenario 'client has pickup for today so one is generated and it is within the pickup cutoff time' do 
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 46.minutes) do
      @worker.perform_async
  
      expect(@client.commercial_pickups.count).to eq 1
  
      # commercial pickup
      expect(@client.commercial_pickups.count).to eq 1
      @pickup = @client.commercial_pickups.first
      expect(@pickup.pick_up_date.today?).to eq true
      expect(@pickup.pick_up_window).to eq @client.pickup_window
      expect(@pickup.full_address).to eq @address.full_address
      expect(@pickup.routable_address).to eq @address.address
      expect(@pickup.detergent).to eq 'hypoallergenic'
      expect(@pickup.softener).to eq 'hypo_allergenic'
      expect(@pickup.pick_up_directions).to eq @address.pick_up_directions
      expect(@pickup.client_price_per_pound).to eq @client.price_per_pound
      # address
      expect(@address.commercial_pickups.count).to eq 1
    end
  end

  scenario '50 clients have a pickup scheduled for today, so 50 are generated' do
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 46.minutes) do
      49.times do |num|
        client = Client.create!(
          name: "#{Faker::Name.name}#{num + 1}",
          phone: '3216549875',
          email: "#{Faker::Internet.email}#{num + 1}",
          special_notes: "#{Faker::Name.name}#{num + 1}",
          contact_person: "#{Faker::Name.name}#{num + 1}",
          area_of_business: "#{Faker::Job.title}#{num + 1}",
          monday: true,
          tuesday: true,
          wednesday: true,
          thursday: true,
          friday: true,
          saturday: true,
          sunday: true,
          pickup_window: Client.pickup_windows.to_a.sample.first,
          price_per_pound: 1.49,
          card_brand: 'visa',
          card_exp_month: '04',
          card_exp_year: '24',
          card_last4: '4242'
        )

        address = client.addresses.new(attributes_for(:address))
        address.skip_geocode = true
        address.save!
      end
  
      @worker.perform_async
  
      expect(Client.count).to eq 50
      expect(CommercialPickup.count).to eq 50
    end
  end

  scenario 'a single client has multiple addresses and a pickup is generated for each address' do
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 46.minutes) do
      49.times do
        @address = @client.addresses.new(attributes_for(:address).merge(street_address: Faker::Address.street_address))
        @address.skip_geocode = true
        @address.save!
      end
  
      @worker.perform_async

      @client.commercial_pickups.each do |pickup|
        # verify address accuracy
        @street_address = pickup.routable_address.split(',').first

        @address = @client.addresses.find_by(street_address: @street_address)

        expect(pickup.address_id).to eq @address.id
        expect(pickup.pick_up_date.today?).to eq true
        expect(pickup.pick_up_window).to eq @client.pickup_window
        expect(pickup.full_address).to eq @address.full_address
        expect(pickup.routable_address).to eq @address.address
        expect(pickup.detergent).to eq 'hypoallergenic'
        expect(pickup.softener).to eq 'hypo_allergenic'
        expect(pickup.pick_up_directions).to eq @address.pick_up_directions
        expect(pickup.client_price_per_pound).to eq @client.price_per_pound
      end
  
      expect(Client.count).to eq 1
      expect(CommercialPickup.count).to eq 50
    end
  end

  scenario 'client has pickup for today but its past the pickup time so a order is not generated' do 
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 44.minutes) do
      @worker.perform_async
  
      expect(@client.commercial_pickups.count).to eq 0
    end
  end

  scenario 'client does not have a pickup for today so a pickup is not generated' do 
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 46.minutes) do
      today = Date.current.strftime("%A").downcase
      @client.update_attribute(
        today, false
      )
      @worker.perform_async
  
      expect(@client.commercial_pickups.count).to eq 0
    end
  end

  scenario 'client cancelled their account so a pickup is not generated' do 
    @client.cancel_account!
    travel_to(Time.parse(Client::PICKUP_CUTOFF_TIME) - 44.minutes) do
      today = Date.current.strftime("%A").downcase
      @client.update_attribute(
        today, false
      )
      @worker.perform_async
  
      expect(@client.commercial_pickups.count).to eq 0
    end
  end

end
