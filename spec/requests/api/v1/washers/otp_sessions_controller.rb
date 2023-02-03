require 'rails_helper'

RSpec.describe 'api/v1/washers/otp_sessions_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer requires otp_authentication and authenticates successfully before the otp_code has expired' do
    post '/api/v1/washers/otp_sessions', params: {
      washer: {
        email: @washer.email,
        password: @washer.password,
        otp_code: @washer.otp_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['message']).to eq 'success'
    expect(json['washer']['full_name']).to eq @washer.full_name.upcase
    expect(json['washer']['email']).to eq @washer.email
    expect(json['auth_token']).to be_present

    # washer
    @washer.reload
    expect(Washer.first.authenticate_with_otp).to eq false
  end

  scenario 'washer requires otp_authentication but the otp_code has expired, their form is valid but they are kicked back' do
    @otp_code = @washer.otp_code

    travel_to(Time.current + 2.hours + 1.minutes) do
      post '/api/v1/washers/otp_sessions', params: {
        washer: {
          email: @washer.email,
          password: @washer.password,
          otp_code: @otp_code
        }
      }
      json = JSON.parse(response.body)
      # p json

      # response.data
      expect(json['code']).to eq 3000
      expect(json['message']).to eq 'failure'
      expect(json['errors']).to eq "Invalid Password or One-Time-Password Code"
      expect(json['auth_token']).to_not be_present

      # washer
      @washer.reload
      expect(@washer.authenticate_with_otp).to eq true
    end
  end

  scenario 'washer does not requier otp_authentication and so an error is returned' do
    @washer.authenticate_otp(@washer.otp_code)
    @washer.disable_authenticate_with_otp

    post '/api/v1/washers/otp_sessions', params: {
      washer: {
        email: @washer.email,
        password: @washer.password,
        otp_code: @otp_code
      }
    }
    json = JSON.parse(response.body)
    # p json

    # response.data
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'failure'
    expect(json['errors']).to eq "Invalid Password or One-Time-Password Code"
    expect(json['auth_token']).to_not be_present

    # washer
    @washer.reload
    expect(@washer.authenticate_with_otp).to eq false
  end
end