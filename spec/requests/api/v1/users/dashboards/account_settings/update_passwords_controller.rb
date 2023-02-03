require 'rails_helper'
RSpec.describe 'api/v1/users/dashboards/account_settings/update_passwords_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    @auth_token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user is not logged in' do
    put '/api/v1/users/dashboards/account_settings/update_passwords',
    params: {
      password: {
        old_password: 'password',
        new_password: 'password1',
        new_password_confirmation: 'password1'
      }
    },
    headers: {
      Authorization: '@auth_token'
    }

    json = JSON.parse(response.body).with_indifferent_access

    # respone

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user updates password successfully' do
    @old_password = 'password'
    @new_password = 'password1'
    @new_password_confirmation = 'password1'
    put '/api/v1/users/dashboards/account_settings/update_passwords',
    params: {
      password: {
        old_password: @old_password,
        new_password: @new_password,
        new_password_confirmation: @new_password_confirmation
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'password_updated'
    # user
    @user.reload
    expect(@user.valid_password?(@new_password)).to eq true
  end

  scenario 'password does not match' do
    @old_password = 'password'
    @new_password = 'password1'
    @new_password_confirmation = 'password123'
    put '/api/v1/users/dashboards/account_settings/update_passwords',
    params: {
      password: {
        old_password: @old_password,
        new_password: @new_password,
        new_password_confirmation: @new_password_confirmation
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access
    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_password'
  end

  scenario 'new passwords match but old password is invalid' do
    @old_password = 'password123'
    @new_password = 'password1'
    @new_password_confirmation = 'password1'
    put '/api/v1/users/dashboards/account_settings/update_passwords',
    params: {
      password: {
        old_password: @old_password,
        new_password: @new_password,
        new_password_confirmation: @new_password_confirmation
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access
    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_password'
  end
end