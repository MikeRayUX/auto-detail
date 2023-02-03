# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'new users controller spec', type: :request do
  scenario 'creates new account with valid info' do
    post '/api/v1/users/new_users', params: {
      user: {
        full_name: Faker::Name.name,
        email: Faker::Internet.email,
        phone: '3216549879',
        password: 'password',
        password_confirmation: 'password'
      }
    }

    json = JSON.parse(response.body)

    expect(json['token']).to be_present
    expect(User.count).to eq(1)
  end

  scenario 'cannot create account with invalid info' do
    post '/api/v1/users/new_users', params: {
      user: {
        full_name: Faker::Name.name,
        email: '',
        phone: '3213213213',
        password: 'password',
        password_confirmation: 'password'
      }
    }

    json = JSON.parse(response.body)
    expect(json['code']).to eq(3000)
  end

  scenario 'user creates an account and received a sign up email' do
    post '/api/v1/users/new_users', params: {
      user: {
        full_name: Faker::Name.name,
        email: Faker::Internet.email,
        phone: '3216549879',
        password: 'password',
        password_confirmation: 'password'
      }
    }

    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
