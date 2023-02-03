require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/direct_deposits_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)

    @region = create(:region, :open_washer_capacity)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/direct_deposits/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer does not have a stripe account, so a new one is created and a link to setup their connect account is returned' do
      get '/api/v1/washers/activations/direct_deposits/new', {
        headers: {
          Authorization: @auth_token
        }
      } 

      json = JSON.parse(response.body)
      # p json

      expect(json['code']).to eq 200
      expect(json['message']).to eq 'setup_not_completed'
      expect(json['url']).to be_present

      # washer
      @washer.reload
      expect(@washer.stripe_account_id).to be_present
  end

end