require 'rails_helper'

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
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is authenticate successfully' do
    # before_action :authenticated?

    post '/api/v1/washers/sessions', params: {
      washer: {
        email: @washer.email,
        password: 'asdfasdf'
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'failure'
    expect(json[:errors]).to eq "Invalid Email and/or Password"
  end

  scenario 'washer is authenticated but has not been invited yet' do
    # before_action :is_invited?

    post '/api/v1/washers/sessions', params: {
      washer: {
        email: @washer.email,
        password: @washer.password
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'failure'
    expect(json[:errors]).to eq 'This account has not yet received an invitation. Once invited, you will receive an invitation email.'
  end

  scenario 'washer is authenticated and was invited but was deactivated' do
    # before_action :is_not_deactivated?
    @washer.invite_for_onboard!('123456')
    @washer.deactivate!

    post '/api/v1/washers/sessions', params: {
      washer: {
        email: @washer.email,
        password: @washer.password
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'failure'
    expect(json[:errors]).to eq 'Your account is not currently activated. Please contact support@freshandtumble.com'
  end

  scenario 'washer is authenticated, invites and is not deactivated so they are authenticated successfully' do
    # before_action :is_not_deactivated?
    @washer.invite_for_onboard!('123456')

    post '/api/v1/washers/sessions', params: {
      washer: {
        email: @washer.email,
        password: @washer.password
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'success'
    expect(json[:washer][:full_name]).to eq @washer.full_name.upcase
    expect(json[:washer][:email]).to eq @washer.email
    expect(json[:auth_token]).to be_present
  end
end