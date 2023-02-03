# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'api/v1/users/resolve_auths_controller', type: :request do
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

    @auth_token = JsonWebToken.encode(sub: @user.id, email: @user.email)

    @invalid_token = @auth_token + '123'
  end

  scenario "user's valid token is verfied but has not completed setup so current_user is returned but no addresss is present" do
    get '/api/v1/users/resolve_auths', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq(200)
    expect(json[:status]).to eq('ok')
    # user
    expect(json[:current_user][:full_name]).to eq @user.full_name.titleize
    expect(json[:current_user][:first_name]).to eq @user.first_name
    expect(json[:current_user][:email]).to eq @user.email.downcase
  end

  scenario "user's valid token is verfied and has completed setup (has address) current_address as well as current_user is returned" do
    @address = @user.create_address!(attributes_for(:address))
    get '/api/v1/users/resolve_auths', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq(200)
    expect(json[:status]).to eq('ok')
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

  scenario "user's invalid token is rejected" do
    get '/api/v1/users/resolve_auths', headers: {
      Authorization: @invalid_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq(3000)
    expect(json[:status]).to eq('unauthorized')
  end
end
