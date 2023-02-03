require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/tax_agreements_controller', type: :request do
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
    get '/api/v1/washers/activations/tax_agreements/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer gets the content for the tax agreements screen' do
    get '/api/v1/washers/activations/tax_agreements/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['tax_agreement']).to be_present
  end

  scenario 'washer accepts the tax agreement and the datetime is recorded' do
    put '/api/v1/washers/activations/tax_agreements/1', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'tax_agreement_accepted'

    @washer.reload

    expect(@washer.tax_agreement_accepted_at.today?).to eq true
    expect(@washer.tax_agreement_accepted_at).to be_present
  end

  scenario 'washer already accepted tax agreement so a already_accepted message is returned' do
    @washer.accept_tax_agreement!

    put '/api/v1/washers/activations/tax_agreements/1', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'tax_agreement_already_accepted'
    expect(json['errors']).to eq 'This section has already been completed.'
  end

end