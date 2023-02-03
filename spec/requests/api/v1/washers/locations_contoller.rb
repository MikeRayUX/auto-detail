require 'rails_helper'
RSpec.describe 'api/v1/washers/offers_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    @region = create(:region, :open_washer_capacity)

    @user = create(:user, :with_payment_method)
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))

    @w = Washer.create!(attributes_for(:washer, :activated).merge(region_id: @region.id))
    @w.go_online

    @auth = JsonWebToken.encode(sub: @w.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer app background Location.startLocationUpdatesAsync begins and successfully updates the washers current_lat and current_lng as well as session is refreshed' do
    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    travel_to(DateTime.current + 3.minutes) do
      put '/api/v1/washers/locations/1', 
      params: {
        washer: {
          current_lat: @lat,
          current_lng: @lng
        }
      },
      headers: {
        Authorization: @auth
      }
  
      json = JSON.parse(response.body)
  
      expect(json['code']).to eq 204
      expect(json['message']).to eq 'location_updated'

      @w.reload

      expect(@w.current_lat).to eq @lat
      expect(@w.current_lng).to eq @lng
    end

  end

  scenario 'no lat lng passed but the session is refreshed anyway' do
    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    travel_to(DateTime.current + 3.minutes) do
      put '/api/v1/washers/locations/1', 
      params: {
        washer: {
          current_lat: '',
          current_lng: ''
        }
      },
      headers: {
        Authorization: @auth
      }
  
      json = JSON.parse(response.body)
  
      p json
      
      expect(json['code']).to eq 3000
      expect(json['message']).to eq 'missing_location'

      @w.reload
    end

  end
end
