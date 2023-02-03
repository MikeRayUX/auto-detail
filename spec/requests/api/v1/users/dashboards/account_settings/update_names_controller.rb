require 'rails_helper'
RSpec.describe 'api/v1/users/dashboards/settings/updaste_names_controller', type: :request do

	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    
    @auth_token = JsonWebToken.encode(sub: @user.id)
	end

	after do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end

  scenario 'user is not signed in' do
    @new_name = 'laskdjfa;lskdkjfaospidf'
		put '/api/v1/users/dashboards/account_settings/update_names', params: {
      user: {
        full_name: @new_name
      }
    },
    headers: {
      Authorization: '@auth_token'
    }

    @user.reload

    json = JSON.parse(response.body).with_indifferent_access
    
    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user updates their name' do
    @new_name = 'laskdjfa;lskdkjfaospidf'
		put '/api/v1/users/dashboards/account_settings/update_names', 
    params: {
      user: {
        full_name: @new_name
      }
    },
    headers: {
      Authorization: @auth_token
    }

    @user.reload

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'user_updated'
    # current_user
    expect(json[:current_user]).to be_present
    expect(json[:current_user][:full_name]).to eq @user.full_name.titleize
    expect(json[:current_user][:first_name]).to eq @user.first_name
    expect(json[:current_user][:email]).to eq @user.email
  end

  scenario 'user enters a blank name and is kicked back' do
    @previous_name = @user.full_name
    @new_name = ''
		put '/api/v1/users/dashboards/account_settings/update_names', params: {
      user: {
        full_name: @new_name
      }
    },
    headers: {
      Authorization: @auth_token
    }

    @user.reload

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'user_not_updated'
    expect(json[:errors]).to be_present
	end

end