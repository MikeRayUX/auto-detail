# frozen_string_literal: true

require 'rails_helper'
require 'format_helper'
RSpec.describe 'resolve setups (add address) controller spec', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    @email = Faker::Internet.email
    @region = create(:region)
    @coverage_area = @region.coverage_areas.create!(attributes_for(:coverage_area))

    @user = User.create!(
      email: @email,
      full_name: Faker::Name.name,
      phone: '3216549879',
      password: 'password',
      password_confirmation: 'password'
    )

    @auth_token = JsonWebToken.encode(sub: @user.id, email: @user.email)
  end

  scenario 'user is not logged in' do
    get '/api/v1/users/resolve_setups', headers: {
      Authorization: ''
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq('auth_error')
  end

  scenario 'user has not completed setup' do
    get '/api/v1/users/resolve_setups', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq('setup_not_completed')
  end

  scenario 'user has already completed setup but is not within a region (outside coverage area)' do
    @address = @user.create_address(
      street_address: '123 high st',
      city: 'seattle',
      state: 'wa',
      zipcode: '98765'
    )

    get '/api/v1/users/resolve_setups', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq('outside_coverage_area')
    # current_address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @address.full_address.upcase
    expect(json[:current_address][:pick_up_directions]).to eq @address.pick_up_directions
    expect(json[:current_address][:truncated_address]).to eq truncate_attribute(@address.street_address, 35).upcase
    expect(json[:current_address][:lat]).to eq @address.latitude
    expect(json[:current_address][:lng]).to eq @address.longitude
  end

  scenario 'user adds an address and it is within region' do
    post '/api/v1/users/resolve_setups',
         params: {
           address: {
             street_address: '123 high st',
             city: 'seattle',
             state: 'wa',
             zipcode: @coverage_area.zipcode
           }
         },
         headers: {
           Authorization: @auth_token
         }
         
    json = JSON.parse(response.body).with_indifferent_access
    @address = @user.address

    # response
    expect(json[:code]).to eq(200)
    expect(json[:message]).to eq('address_saved')
    # current_address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @address.full_address.upcase
    expect(json[:current_address][:pick_up_directions]).to eq @address.pick_up_directions
    expect(json[:current_address][:truncated_address]).to eq truncate_attribute(@address.street_address, 35).upcase
    expect(json[:current_address][:lat]).to eq @address.latitude
    expect(json[:current_address][:lng]).to eq @address.longitude
    # address
    @user.reload
    expect(@address.region).to be_present
  end

  scenario 'user is unable to complete setup due to address having invalid data' do
    post '/api/v1/users/resolve_setups',
         params: {
           address: {
             street_address: '123 high st',
             city: 'seattle',
             state: '',
             zipcode: '98765'
           }
         },
         headers: {
           Authorization: @auth_token
         }

    json = JSON.parse(response.body).with_indifferent_access
    # p json

    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq 'address_invalid'
  end
end
