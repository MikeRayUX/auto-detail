require 'rails_helper'

RSpec.describe 'api/v1/washers/forgot_passwords_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'washer account doesnt exist' do
    # before_action :account_exists?

    get '/api/v1/washers/forgot_passwords/new', 
    params: {
        washer: {
          email: nil 
        }
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'password_reset_email_sent'
  end

  scenario 'washer enters a valid email and a password reset email is sent containing an otp (one time password)' do
    # before_acton :account_exists?

    get '/api/v1/washers/forgot_passwords/new', 
    params: {
        washer: {
          email: @washer.email
        }
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'password_reset_email_sent'
    expect(json[:details]).to eq 'If an account exists with this email, a password recovery email has been sent to the email you provided'

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.last
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@html_email).to include(@washer.otp_code)
    expect(@text_email).to include(@washer.otp_code)
  end

  scenario 'washer enters a valid otp code but its past the otp time limit' do
    # before_action :valid_otp?, only: %i[update]
    @otp_code = @washer.otp_code
    travel_to(DateTime.current + (Washer::RESET_PASSWORD_TIME_LIMIT + 1.minutes)) do
      put '/api/v1/washers/forgot_passwords', 
      params: {
          washer: {
            email: @washer.email,
            password: 'password',
            password_confirmation: 'password',
            otp_code: @otp_code
          }
        }
  
      json = JSON.parse(response.body).with_indifferent_access
  
      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'invalid_code'
      expect(json[:errors]).to eq 'The confirmation code you entered is either invalid or has expired'
    end
  end

  scenario 'the otp code is invalid' do
    # before_action :valid_otp?, only: %i[update]
    travel_to(DateTime.current + (Washer::RESET_PASSWORD_TIME_LIMIT - 1.minutes)) do
      put '/api/v1/washers/forgot_passwords', 
      params: {
          washer: {
            email: @washer.email,
            password: 'password',
            password_confirmation: 'password',
            otp_code: '@otp_code'
          }
        }
  
      json = JSON.parse(response.body).with_indifferent_access
  
      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'invalid_code'
      expect(json[:errors]).to eq 'The confirmation code you entered is either invalid or has expired'
    end
  end

  scenario 'washer enters a valid otp code and their password is reset successfully within the time limit' do
  # before_action :valid_otp?, only: %i[update]
    travel_to(DateTime.current + (Washer::RESET_PASSWORD_TIME_LIMIT - 1.minutes)) do
      put '/api/v1/washers/forgot_passwords', 
      params: {
          washer: {
            email: @washer.email,
            password: 'password',
            password_confirmation: 'password',
            otp_code: @washer.otp_code
          }
        }
  
      json = JSON.parse(response.body).with_indifferent_access
  
      expect(json[:code]).to eq 204
      expect(json[:message]).to eq 'password_updated_successfully'
    end
  end

end