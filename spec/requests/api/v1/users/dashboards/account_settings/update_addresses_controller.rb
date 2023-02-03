# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/users/dashboards/account_settings/update_addresses_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @email = Faker::Internet.email
    @region = create(:region)
    @coverage_area = @region.coverage_areas.create!(attributes_for(:coverage_area))

    @user = User.create!(
      email: Faker::Internet.email,
      full_name: Faker::Name.name,
      phone: '3216549879',
      password: 'password',
      password_confirmation: 'password'
    )
    @auth_token = JsonWebToken.encode(sub: @user.id, email: @user.email)
  end

  scenario 'user is not logged in' do
    put '/api/v1/users/dashboards/account_settings/update_addresses',
         params: {
           address: {
             street_address: '123 high st',
             city: 'seattle',
             state: 'wa',
             zipcode: @coverage_area.zipcode
           }
         },
         headers: {
           Authorization: 'asdffdas'
         }

    json = JSON.parse(response.body).with_indifferent_access
    # p json
    @address = @user.address

    # response
    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq('auth_error')
  end

  scenario 'user adds an address and it is within region' do
    put '/api/v1/users/dashboards/account_settings/update_addresses',
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
    # p json
    @address = @user.address

    # response
    expect(json[:code]).to eq(200)
    expect(json[:message]).to eq('address_saved')
    # address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @address.full_address.upcase
    expect(json[:current_address][:truncated_address]).to eq @address.street_address.upcase
    expect(json[:current_address][:lat]).to eq @address.latitude
    expect(json[:current_address][:lng]).to eq @address.longitude
    expect(json[:current_address][:pick_up_directions]).to eq @address.pick_up_directions
    # address
    @user.reload
    expect(@address.region).to be_present
  end

  scenario 'user already has an address so their new address is updated' do
    @old_address = @user.create_address!(attributes_for(:address))
    @new_street = '555 new st'
    @new_city = 'long beach'
    @new_state = 'ca'
    @new_zipcode = @coverage_area.zipcode
    @new_unit_number = '555 sad'
    @new_pick_up_directions = 'on the side of the mountain'

    @new_address = Address.new(
      street_address: @new_street,
      city: @new_city,
      state: @new_state,
      zipcode: @new_zipcode,
      pick_up_directions: @new_pick_up_directions
    )

    put '/api/v1/users/dashboards/account_settings/update_addresses',
        params: {
          address: {
            street_address: @new_street,
            city: @new_city,
            state: @new_state,
            zipcode: @new_zipcode,
            pick_up_directions: @new_pick_up_directions
          }
        },
        headers: {
          Authorization: @auth_token
        }
         
    json = JSON.parse(response.body).with_indifferent_access

    @user.reload
    @address = @user.address

    # response
    expect(json[:code]).to eq(200)
    expect(json[:message]).to eq('address_saved')
    # address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @new_address.full_address.upcase
    expect(json[:current_address][:truncated_address]).to eq @new_address.street_address.upcase
    expect(json[:current_address][:lat]).to be_present
    expect(json[:current_address][:lng]).to be_present
    expect(json[:current_address][:pick_up_directions]).to eq @new_address.pick_up_directions
    # address
    @user.reload
    expect(@address.region).to be_present
  end

  scenario 'user updates their address to an address that is outside coverage so address does not have a region' do
    @old_address = @user.create_address!(attributes_for(:address))
    @new_street = '555 new st'
    @new_city = 'long beach'
    @new_state = 'ca'
    @new_zipcode = '55555'
    @new_unit_number = '555 sad'
    @new_pick_up_directions = 'on the side of the mountain'

    @new_address = Address.new(
      street_address: @new_street,
      city: @new_city,
      state: @new_state,
      zipcode: @new_zipcode,
      pick_up_directions: @new_pick_up_directions
    )

    put '/api/v1/users/dashboards/account_settings/update_addresses',
        params: {
          address: {
            street_address: @new_street,
            city: @new_city,
            state: @new_state,
            zipcode: @new_zipcode,
            pick_up_directions: @new_pick_up_directions
          }
        },
        headers: {
          Authorization: @auth_token
        }
         
    json = JSON.parse(response.body).with_indifferent_access

    @user.reload
    @address = @user.address

    # response
    expect(json[:code]).to eq(200)
    expect(json[:message]).to eq('address_saved')
    # address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @new_address.full_address.upcase
    expect(json[:current_address][:truncated_address]).to eq @new_address.street_address.upcase
    expect(json[:current_address][:lat]).to be_present
    expect(json[:current_address][:lng]).to be_present
    expect(json[:current_address][:pick_up_directions]).to eq @new_address.pick_up_directions
    # address
    @user.reload
    expect(@address.region).to_not be_present
  end

  scenario 'user is unable to complete setup due to address having invalid data' do
    put '/api/v1/users/dashboards/account_settings/update_addresses',
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

    expect(json[:code]).to eq(3000)
    expect(json[:message]).to eq 'address_invalid'
  end
end
