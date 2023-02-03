require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/background_checks_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)

    @region = create(:region, :open_washer_capacity)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/background_checks/new',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer has not submitted data for background check so they are allowed to continue' do
    get '/api/v1/washers/activations/background_checks/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'not_yet_submitted'
    expect(json['code']).to eq 200
  end

  scenario 'washer has already submitted background check and is kicked back' do
    @washer.mark_background_check_submitted!

    get '/api/v1/washers/activations/background_checks/new', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'already_submitted'
    expect(json['code']).to eq 200
  end

  scenario 'washer submits valid data for background check and it is accepted' do

    put '/api/v1/washers/activations/background_checks/1', { params: {
      washer: {
        first_name: Faker::Name.first_name,
        middle_name: Faker::Name.middle_name,
        last_name: Faker::Name.last_name,
        ssn: "#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}",
        date_of_birth: Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d'),
        phone: '4055555555',
        drivers_license: '12121232123'
      },
      address: {
        street_address:Faker::Address.street_address,
        unit_number: '12A',
        city: 'seattle',
        state: 'wa',
        zipcode: '98168'
      },
      
    },
    headers: {
      Authorization: @auth_token
    }
  }
    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'submitted_successfully'
    expect(json['code']).to eq 202

    # washer
    @washer.reload
    expect(@washer.first_name).to be_present
    expect(@washer.last_name).to be_present
    expect(@washer.ssn).to be_present
    expect(@washer.phone).to be_present
    expect(@washer.date_of_birth).to be_present
    expect(@washer.drivers_license).to be_present
    expect(@washer.background_check_submitted_at.today?).to eq true
    # address
    @address = @washer.address
    expect(@address.street_address).to be_present
    expect(@address.unit_number).to be_present
    expect(@address.city).to be_present
    expect(@address.state).to be_present
    expect(@address.zipcode).to be_present
  end

  scenario 'washer already submitted their data for a background check and tries to resubmit but is kicked back' do
    @washer.mark_background_check_submitted!

    put '/api/v1/washers/activations/background_checks/1', { params: {
      washer: {
        first_name: Faker::Name.first_name,
        middle_name: Faker::Name.middle_name,
        last_name: Faker::Name.last_name,
        ssn: "#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}",
        date_of_birth: Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d'),
        phone: '4055555555',
        drivers_license: '12121232123'
      },
      address: {
        street_address:Faker::Address.street_address,
        unit_number: '12A',
        city: 'seattle',
        state: 'wa',
        zipcode: '98168'
      },
      
    },
    headers: {
      Authorization: @auth_token
    }
  }
    json = JSON.parse(response.body)

    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'failure'
    expect(json['code']).to eq 3000
    expect(json['errors']).to eq 'A background check has already been submitted.'
  end

  scenario 'address is not valid so background check is rejected' do
    put '/api/v1/washers/activations/background_checks/1', { params: {
      washer: {
        first_name: Faker::Name.first_name,
        middle_name: Faker::Name.middle_name,
        last_name: Faker::Name.last_name,
        ssn: "#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}",
        date_of_birth: Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d'),
        phone: '4055555555',
        drivers_license: '123123123'
      },
      address: {
        street_address:Faker::Address.street_address,
        unit_number: '12A',
        city: '',
        state: 'wa',
        zipcode: '98168'
      },
      
    },
    headers: {
      Authorization: @auth_token
    }
  }
    json = JSON.parse(response.body) 
  
    expect(json['status']).to eq 'ok'
    expect(json['message']).to eq 'failure'
    expect(json['code']).to eq 3000
    expect(json['errors']).to be_present

    # washer
    @washer.reload
    expect(@washer.first_name).to_not be_present
    expect(@washer.last_name).to_not be_present
    expect(@washer.ssn).to_not be_present
    expect(@washer.date_of_birth).to_not be_present
    expect(@washer.drivers_license).to_not be_present
    # address
    @address = @washer.address
    expect(@address).to_not be_present
  end

end