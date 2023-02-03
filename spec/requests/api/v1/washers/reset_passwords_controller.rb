require 'rails_helper'
require 'offer_helper'

RSpec.describe 'api/v1/washers/sessions_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    
    @region = create(:region)
    @washer = Washer.new(attributes_for(:washer).merge(
      region_id: @region.id
    ))
    @washer.skip_finalized_washer_attributes = true
    @washer.save!
    @address = @washer.create_address!(attributes_for(:address))

    @auth = JsonWebToken.encode(sub: @washer.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is authenticate successfully' do
    # before_action :authenticate_washer!

    put '/api/v1/washers/reset_passwords', {
      params: {
        password_change: {
          current_password: '',
          new_password: 'asdfasdf',
          new_new_password_confirmation: ''
        },
      },
      headers: {
        Authorization: ''
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
    expect(json[:errors]).to eq ['Your session has expired. Please log in to continue.']
  end

  scenario 'current password is invalid' do
    # before_action :current_password_valid?

    put '/api/v1/washers/reset_passwords', {
      params: {
        password_change: {
          current_password: 'sadf',
          new_password: 'asdfasdf',
          new_password_confirmation: 'asdasdf'
        },
      },
      headers: {
        Authorization: @auth
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_current_password'
    expect(json[:errors]).to eq 'Invalid Password'
  end

  scenario 'the current password is valid but the new passwords do not match' do
    # before_action :current_password_valid?

    put '/api/v1/washers/reset_passwords', {
      params: {
        password_change: {
          current_password: 'password',
          new_password: 'asdfasdf',
          new_password_confirmation: 'asdasdf'
        },
      },
      headers: {
        Authorization: @auth
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_password'
    expect(json[:errors]).to eq "Password confirmation doesn't match Password"
  end

  scenario 'the password matches and is updated succesffully' do
    # before_action :current_password_valid?

    put '/api/v1/washers/reset_passwords', {
      params: {
        password_change: {
          current_password: 'password',
          new_password: '123456',
          new_password_confirmation: '123456'
        },
      },
      headers: {
        Authorization: @auth
      }
    }
    
    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'password_updated'
    expect(json[:details]).to eq 'Your Password Was Updated Successfully'
    # washer
    @washer.reload
    expect(@washer.valid_password?('123456')).to eq true
  end
end