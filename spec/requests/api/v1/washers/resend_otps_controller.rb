require 'rails_helper'

RSpec.describe 'api/v1/washers/resend_otps_controller', type: :request do
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

  scenario 'washer requires otp_authenticaton and requests a new one time password and one is sent to their email address' do
    post '/api/v1/washers/resend_otps', params: {
      washer: {
        email: @washer.email,
        password: @washer.password,
      }
    }

    json = JSON.parse(response.body)

    # response
    expect(json['code']).to eq 200
    expect(json['message']).to eq "Please check your email: #{@washer.email} for a new One Time Password"

    # email
    @email = ActionMailer::Base.deliveries.first
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(@email.to).to match([@washer.email])
    expect(@email.from).to match(['no-reply@freshandtumble.com'])
    expect(@email.subject).to match("Your One Time Password")

    # html email
    @html_email = @email.html_part.body
    expect(@html_email).to include("Your Security is important to us.")
    expect(@html_email).to include("Once you've successfully logged in with the password you used to sign up with, you will be asked to use the One Time Password below to confirm your email address.")
    expect(@html_email).to include(@washer.otp_code)

    # text email
    @text_email = @email.text_part.body
    expect(@text_email).to include("Your Security is important to us.")
    expect(@text_email).to include("Once you've successfully logged in with the password you used to sign up with, you will be asked to use the One Time Password below to confirm your email address.")
    expect(@text_email).to include(@washer.otp_code)
  end

  scenario 'washer requires otp_authenticaton but submits invalid password and no email is sent' do
    post '/api/v1/washers/resend_otps', params: {
      washer: {
        email: @washer.email,
        password: 'asdfasdf',
      }
    }

    json = JSON.parse(response.body)

    # response
    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'failure'
    expect(json['errors']).to eq "Cannot resend One Time Password, Please log in again."

    # email
    @email = ActionMailer::Base.deliveries.first
    expect(ActionMailer::Base.deliveries.count).to eq 0
  end

end