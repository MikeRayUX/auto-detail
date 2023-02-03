# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'sessions controller spec', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    @email = Faker::Internet.email

    @user = User.create!(
      email: @email,
      full_name: Faker::Name.name,
      phone: '3216549879',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  scenario 'user can sign in with valid info' do
    post '/api/v1/users/sessions', params: {
      user: {
        email: @email,
        password: 'password'
      }
    }

    json = JSON.parse(response.body).with_indifferent_access
    token = json[:data][:token]

    decoded_token = JsonWebToken.decode(token).first
    expect(decoded_token['sub']).to eq(@user.id)


    expect(json[:current_user][:full_name]).to eq @user.full_name.titleize
    expect(json[:current_user][:first_name]).to eq @user.first_name
    expect(json[:current_user][:email]).to eq @user.email.downcase
    # address
    expect(json[:current_address]).to eq nil
  end


  scenario 'user signs in and has an address, so the address is returned' do
    @address = @user.create_address!(attributes_for(:address))

    post '/api/v1/users/sessions', params: {
      user: {
        email: @email,
        password: 'password'
      }
    }

    json = JSON.parse(response.body).with_indifferent_access
    token = json[:data][:token]

    decoded_token = JsonWebToken.decode(token).first
    expect(decoded_token['sub']).to eq(@user.id)

    # user
    expect(json[:current_user][:full_name]).to eq @user.full_name.titleize
    expect(json[:current_user][:first_name]).to eq @user.first_name
    expect(json[:current_user][:email]).to eq @user.email.downcase
    # address
    expect(json[:current_address]).to be_present
    expect(json[:current_address][:full_address]).to eq @address.full_address.upcase
    expect(json[:current_address][:truncated_address]).to be_present
    expect(json[:current_address][:lat]).to eq @address.latitude
    expect(json[:current_address][:lng]).to eq @address.longitude
    expect(json[:current_address][:pick_up_directions]).to eq @address.pick_up_directions
  end

  scenario 'user can sign out, the token jti is added to the blacklist, and they can no longer access token protected controllers' do
    post '/api/v1/users/sessions', params: {
      user: {
        email: @email,
        password: 'password'
      }
    }

    token = JSON.parse(response.body)['data']['token']
    decoded_token = JsonWebToken.decode(token).first
    new_jti = decoded_token['jti']

    delete '/api/v1/users/sessions', headers: {
      Authorization: token
    }

    expect(JwtBlacklist.first.jti).to eq(new_jti)

    # p JwtBlacklist.first

    get '/api/v1/users/resolve_auths', headers: {
      Authorization: token
    }
    
    json = JSON.parse(response.body)

    # p json

    expect(json['errors'].first).to eq('Your session has expired. Please log in to continue.')
    expect(json['status']).to eq('unauthorized')
  end

  scenario 'user gets a valid token and can now use it to authenticate in other controllers' do
    post '/api/v1/users/sessions', params: {
      user: {
        email: @email,
        password: 'password'
      }
    }

    token = JSON.parse(response.body)['data']['token']
    decoded_token = JsonWebToken.decode(token).first
    new_jti = decoded_token['jti']

    # p decoded_token

    get '/api/v1/users/resolve_auths', headers: {
      Authorization: token
    }
    json = JSON.parse(response.body)

    expect(json['status']).to eq('ok')
  end


  scenario 'user cannot sign in with invalid info' do
    post '/api/v1/users/sessions', params: {
      user: {
        email: @email,
        password: 'pass'
      }
    }

    json = JSON.parse(response.body)
    expect(json['data']['token']).to_not be_present

    expect(json['code']).to eq(3000)
    expect(json['message']).to eq('failure')
    expect(json['data']['errors']).to be_present
    expect(json['status']).to eq('unauthorized')
  end
end
