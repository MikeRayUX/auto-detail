# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'new users controller spec', type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'creates a new account with valid info and gets an email' do
    @password = Faker::Internet.password

    @new_user = {
      full_name: Faker::Name.name,
      phone: '1231231232',
      email: 'arriaga562@gmail.com',
      password: @password,
      password_confirmation: @password
    }

    post users_registrations_path params: {
      user: {
        full_name: @new_user[:full_name],
        phone: @new_user[:phone],
        email: @new_user[:email],
        password: @new_user[:password]
      }
    }

    expect(User.count).to eq(1)
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(response).to redirect_to users_dashboards_homes_path

	end
	
	scenario 'user enters an odd phone number and it is sanitized' do
		@odd_phone_number = '+1(562)787-2684'

    @new_user = {
      full_name: Faker::Name.name,
      phone: @odd_phone_number,
      email: Faker::Internet.email,
      password: 'password',
      password_confirmation: 'password'
    }

    post users_registrations_path params: {
      user: {
        full_name: @new_user[:full_name],
        phone: @new_user[:phone],
        email: @new_user[:email],
        password: @new_user[:password]
      }
		}

		expect(User.first.phone).to eq '5627872684'
  end

  scenario 'cannot create a new account with invalid info' do
    @password = Faker::Internet.password

    @new_user = {
      full_name: Faker::Name.name,
      phone: '',
      email: Faker::Internet.email,
      password: @password,
      password_confirmation: @password
    }

    post users_registrations_path params: {
      user: {
        full_name: @new_user[:full_name],
        phone: @new_user[:phone],
        email: @new_user[:email],
        password: @new_user[:password]
      }
    }

    expect(response).to redirect_to signup_path
    expect(User.count).to eq(0)
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(flash[:error]).to be_present
  end
end