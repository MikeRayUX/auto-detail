require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/resolve_setups_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)


    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/resolve_setups',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'No application sections have been completed so they are returned with a status and enabled boolean' do
    get '/api/v1/washers/activations/resolve_setups',headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['message']).to eq 'setup_not_resolved'
  end

  scenario 'washer has completed application but they have not been activated yet because their application is still being processed' do
    @region = create(:region)

    # attributes
    @washer.update_attributes!(attributes_for(:washer, :applied).merge(region_id: @region.id))
    # models
    @washer.create_address!(attributes_for(:address).merge(region_id: @region.id))
    # application sections
    @washer.complete_app_intro!
    @washer.accept_tos!
    @washer.complete_eligibility_application!
    @washer.mark_background_check_submitted!
    @washer.accept_tax_agreement!
    @washer.create_stripe_account!

    @washer.reload

    get '/api/v1/washers/activations/resolve_setups',headers: {
      Authorization: @auth_token
    }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['message']).to eq 'setup_not_resolved'
  end

  scenario 'washer has completed setup and they are activated so a setup_resolved message is returned' do
    @region = create(:region)

    @washer.update_attributes!(attributes_for(:washer, :applied).merge(region_id: @region.id))

    @washer.create_address!(attributes_for(:address).merge(region_id: @region.id))

    # complete activation application sections
    @washer.complete_app_intro!
    @washer.accept_tos!
    @washer.complete_eligibility_application!
    @washer.mark_background_check_submitted!
    @washer.activate!
    @washer.accept_tax_agreement!
    @washer.create_stripe_account!
    @temp_password = Devise.friendly_token.first(6)

    @washer.update(
      live_within_region: true,
      min_age: true,
      legal_to_work: true,
      has_equipment: true,
      valid_drivers_license: true,
      valid_car_insurance_coverage: true,
      reliable_transportation: true,
      valid_ssn: true,
      consent_to_background_check: true,
      can_lift_30_lbs: true,
      has_disability: false
    )

    @washer.invite_for_onboard!(@temp_password)


    @washer.reload

    # byebug

    get '/api/v1/washers/activations/resolve_setups',headers: {
      Authorization: @auth_token
    }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['message']).to eq 'setup_resolved'
  end

end