require 'rails_helper'
RSpec.describe 'api/v1/washers/registrations_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    rand(5..25).times do |num|
      Region.create(attributes_for(:region, :open_washer_capacity).merge(area: "area#{num}"))
    end 

    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: Region.first.id))
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'the form is valid and a new washer is created with an inactive status awaiting approval' do
    post '/api/v1/washers/registrations', params: {
      washer: {
        full_name: Faker::Name.first_name,
        email: Faker::Internet.email,
        password: 'password',
      },
    }

    json = JSON.parse(response.body)

    p json
    
    washer = Washer.first

    expect(json['code']).to eq 201
    expect(json['flash']).to  eq "Please check your email #{washer.email} for a One Time Password (OTP) to log in to your account."

    # washer
    expect(Washer.count).to eq 1
    expect(washer.activated_at).to_not be_present
    expect(washer.email).to be_present
    expect(washer.full_name).to be_present
    # email
    @email = ActionMailer::Base.deliveries.first
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(@email.to).to match([washer.email])
    expect(@email.from).to match(['no-reply@freshandtumble.com'])
    expect(@email.subject).to match("Your One Time Password")

    # html email
    @html_email = @email.html_part.body
    expect(@html_email).to include("Your Security is important to us.")
    expect(@html_email).to include("Once you've successfully logged in with the password you used to sign up with, you will be asked to use the One Time Password below to confirm your email address.")
    expect(@html_email).to include(washer.otp_code)

    # text email
    @text_email = @email.text_part.body
    expect(@text_email).to include("Your Security is important to us.")
    expect(@text_email).to include("Once you've successfully logged in with the password you used to sign up with, you will be asked to use the One Time Password below to confirm your email address.")
    expect(@text_email).to include(washer.otp_code)
  end

  scenario 'the form is  not valid and a errors are returned' do
    post '/api/v1/washers/registrations', params: {
      washer: {
        email: 'asdfasdf',
        password: 'password',
      },
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['errors']).to be_present

    # washer
    expect(Washer.count).to eq 0

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 0
  end
end