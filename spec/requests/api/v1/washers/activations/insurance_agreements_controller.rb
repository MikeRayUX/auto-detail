require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/insurance_agreements_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/insurance_agreements/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer gets the content for the insurance agreement screen' do
    get '/api/v1/washers/activations/insurance_agreements/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['insurance_agreement']).to be_present
  end

  scenario 'washer accepts the insurance agreement' do
    put '/api/v1/washers/activations/insurance_agreements/1', headers: {
      Authorization: @auth_token
    }

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'insurance_agreement_accepted'

    # washer
    expect(@washer.insurance_agreement_accepted_at).to be_present
    expect(@washer.insurance_agreement_accepted_at.today?).to eq true
  end

  scenario 'washer tries to complete this section twice' do
    @washer.accept_insurance_agreement!

    put '/api/v1/washers/activations/insurance_agreements/1', headers: {
      Authorization: @auth_token
    }

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'insurance_agreement_already_accepted'
    expect(json['errors']).to be_present
    expect(json['errors']).to eq 'This section has already been completed.'

    # washer
    expect(@washer.insurance_agreement_accepted_at).to be_present
  end

end