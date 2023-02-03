
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/washers/resolve_auths_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @region = create(:region)
    
    @w = Washer.new(attributes_for(:washer))
    @w.skip_finalized_washer_attributes = true
    @w.save!
    @w = Washer.last
    
    @auth_token = JsonWebToken.encode(sub: @w.email)
    @invalid_auth_token = @auth_token + '123'
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'invalid or expired token is passed to auth_error is retured' do
    get '/api/v1/washers/resolve_auths', headers: {
      Authorization: @invalid_auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'valid token is passed but the washer is not activated or has completed setup so authenticated_but_setup_not_resolved is returned taking them to the activation steps screen' do
    get '/api/v1/washers/resolve_auths', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'authenticated_but_setup_not_resolved'
  end

  scenario 'valid token is passed and the washer is activated and has completed setup so authenticated and setup resolved is returned taking them to the main dashboard screen' do
    @w.create_address(attributes_for(:address))
    @w.update_attributes!(attributes_for(:washer, :activated).merge(region_id: @region.id))
    @w.reload

    # byebug
    get '/api/v1/washers/resolve_auths', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'authenticated_and_setup_resolved'
  end
  
end
