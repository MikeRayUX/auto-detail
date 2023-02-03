require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/introductions_controller', type: :request do
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
    get '/api/v1/washers/activations/introductions/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer gets the content for the introduction screen' do
    get '/api/v1/washers/activations/introductions/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['content']).to be_present
  end

  scenario 'washer completes the intro section of the app' do
    put '/api/v1/washers/activations/introductions/1', headers: {
      Authorization: @auth_token
    }

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'intro_completed'

    # washer
    expect(@washer.completed_app_intro_at).to be_present
    expect(@washer.completed_app_intro_at.today?).to eq true
  end

  scenario 'washer tries to complete this section twice' do
    @washer.complete_app_intro!

    put '/api/v1/washers/activations/introductions/1', headers: {
      Authorization: @auth_token
    }

    @washer.reload

    json = JSON.parse(response.body)

    # response
    expect(json['status']).to eq 'ok'
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'intro_already_completed'
    expect(json['errors']).to be_present
    expect(json['errors']).to eq 'This section has already been completed.'

    # washer
    expect(@washer.completed_app_intro_at).to be_present
  end

end