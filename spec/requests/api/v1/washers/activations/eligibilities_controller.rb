require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/eligibilities_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)

    @region = create(:region, :open_washer_capacity)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/eligibilities/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer gets eligibility application' do
    get '/api/v1/washers/activations/eligibilities/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'regions_available'
    expect(json['code']).to eq 200
    expect(json['regions']).to be_present
    expect(json['eligibility_questions']).to be_present
  end

  scenario 'there are no regions with availability capacity so a no_available_regions message is returned' do
    get '/api/v1/washers/activations/eligibilities/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'regions_available'
    expect(json['code']).to eq 200
    expect(json['regions']).to be_present
    expect(json['eligibility_questions']).to be_present
  end

  scenario 'there are no regions with washer capcity so a no_available_regions notice is returned' do
    @region.update(attributes_for(:region, :no_washer_capacity))

    get '/api/v1/washers/activations/eligibilities/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'no_available_regions'
    expect(json['regions']).to_not be_present
    expect(json['eligibility_questions']).to_not be_present
  end

  
  scenario 'there are no regions at all so a no_available_regions notice is returned' do
    Region.destroy_all

    get '/api/v1/washers/activations/eligibilities/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'no_available_regions'
    expect(json['regions']).to_not be_present
    expect(json['eligibility_questions']).to_not be_present
  end

  scenario "washer submits eligibilities questionaire successfully and a region exists so it's valid" do
    put '/api/v1/washers/activations/eligibilities/1', params: {
      eligibility: {
        region_id: @region.id
      }
    }, headers: {
      Authorization: @auth_token
    }
    

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'application_submitted'

    # washer
    expect(@washer.region).to be_present
    expect(@washer.eligibility_completed_at).to be_present
    expect(@washer.eligibility_completed_at.today?).to eq true
  end

  scenario 'washer tries to submit questionaire twice' do
    @washer.complete_eligibility_application!

    put '/api/v1/washers/activations/eligibilities/1', params: {
      eligibility: {
        region_id: @region.id
      }
    }, headers: {
      Authorization: @auth_token
    }

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'already_submitted'
    expect(json['errors']).to eq 'This section has already been completed.'

    # washer
    expect(@washer.eligibility_completed_at).to be_present
    expect(@washer.eligibility_completed_at.today?).to eq true
  end

end