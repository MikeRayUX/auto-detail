# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'sessions controller spec', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @password = Faker::Internet.password

    @new_user = {
      full_name: Faker::Name.name,
      phone: '1231231232',
      email: Faker::Internet.email,
      password: @password,
      password_confirmation: @password
    }

    @user = User.create!(
      full_name: @new_user[:full_name],
      phone: @new_user[:phone],
      email: @new_user[:email],
      password: @new_user[:password],
      password_confirmation: @new_user[:password_confirmation]
    )

    @user = User.first
  end

  scenario 'user can log in' do
    post user_session_path, params: {
      user: {
        email: @new_user[:email],
        password: @new_user[:password]
      }
    }

    expect(response).to redirect_to users_dashboards_homes_path
  end

  scenario 'user provides invalid login info and is redirected back' do
    post user_session_path, params: {
      user: {
        email: @new_user[:email],
        password: @new_user[:password] + rand(100).to_s
      }
    }
    expect(response.body).to include('Invalid Email or password.')
  end

  scenario 'user can log out' do
    sign_in @user

    delete destroy_user_session_path

    expect(response).to redirect_to signin_path
  end
end
