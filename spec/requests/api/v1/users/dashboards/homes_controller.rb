# frozen_string_literal: true

require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/users/dahsboards/homes_controller', type: :request do
  before do
    @region = create(:region)

    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))
    @user = create(:user)
    @address = @user.build_address(
      attributes_for(:address, :with_fake_geocode)
    )
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach

    @auth_token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    sign_out @user
  end

  scenario 'user is not logged in' do
    get '/api/v1/users/dashboards/homes', params: {
      
    }, 
    headers: {
      Authorization: '@auth_token'
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user logs in and is taken to the home screen, they have no orders, but a message of the day is returned' do
    get '/api/v1/users/dashboards/homes', params: {
      
    }, 
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'orders_returned'
    expect(json[:orders].count).to eq 0
    expect(json[:motd]).to eq "Welcome Back #{@user.first_name}!!"
  end

  scenario 'user has an order in progress (asap) order so it is returned but only with selected attributes' do
    create_open_offers(1)

    get '/api/v1/users/dashboards/homes', params: {
      
    }, 
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'orders_returned'
    expect(json[:orders].count).to eq 1
    expect(json[:motd]).to eq "Welcome Back #{@user.first_name}!!"
  end
end
