require 'rails_helper'

RSpec.describe 'api/v1/washers/activations/application_statuses_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @w = Washer.new(attributes_for(:washer))
    @w.skip_finalized_washer_attributes = true
    @w.save
    @w.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @w.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check success' do
    get '/api/v1/washers/activations/application_statuses',headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'auth_error'
  end

  scenario 'washer has not completed app intro so an incomplete and disabled status is returned' do
    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['introductions']['status']).to eq 'incomplete'
    expect(json['application']['introductions']['enabled']).to eq true
  end

  scenario 'washer has completed app intro so an complete and enabled status is returned' do
    @w.complete_app_intro!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['introductions']['status']).to eq 'complete'
    expect(json['application']['introductions']['enabled']).to eq false
  end

  scenario 'washer has not accepted terms of service so incomplete and enabled:false is returned' do
    @w.complete_app_intro!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['terms_of_services']['status']).to eq 'incomplete'
    expect(json['application']['terms_of_services']['enabled']).to eq true
  end

  scenario 'washer has accepted terms of service so complete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['terms_of_services']['status']).to eq 'complete'
    expect(json['application']['terms_of_services']['enabled']).to eq false
  end

  scenario 'washer has not completed eligibilities form so incomplete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['eligibilities']['status']).to eq 'incomplete'
    expect(json['application']['eligibilities']['enabled']).to eq true
  end

  scenario 'washer has completed eligibilities form so complete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['eligibilities']['status']).to eq 'complete'
    expect(json['application']['eligibilities']['enabled']).to eq false
  end

  scenario 'washer has not completed background check application' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['background_checks']['status']).to eq 'incomplete'
    expect(json['application']['background_checks']['enabled']).to eq true
  end

  scenario 'washer has submitted the background check application but it is pending approval' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['background_checks']['status']).to eq 'pending'
    expect(json['application']['background_checks']['enabled']).to eq false
    expect(json['application']['background_checks']['message']).to eq "Submitted on #{@w.background_check_submitted_at.strftime('%m/%d/%Y')}"
  end

  scenario 'washer has submitted the background check and it was approved' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!
    @w.approve_background_check!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['background_checks']['status']).to eq 'complete'
    expect(json['application']['background_checks']['enabled']).to eq false
    expect(json['application']['background_checks']['message']).to eq "Approved on #{@w.background_check_approved_at.strftime('%m/%d/%Y')}"
  end

  scenario 'washer has not completed incurance form so incomplete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['insurances']['status']).to eq 'incomplete'
    expect(json['application']['insurances']['enabled']).to eq true
  end

  scenario 'washer has completed incurance form so complete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.accept_insurance_agreement!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['insurances']['status']).to eq 'complete'
    expect(json['application']['insurances']['enabled']).to eq false
  end

  scenario 'washer has not completed incurance form so incomplete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['insurances']['status']).to eq 'incomplete'
    expect(json['application']['insurances']['enabled']).to eq true
  end

  scenario 'washer has not accepted tax_agreement so incomplete and enabled:true is returned' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!
    @w.approve_background_check!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['tax_agreements']['status']).to eq 'incomplete'
    expect(json['application']['tax_agreements']['enabled']).to eq true
  end
  
  scenario 'washer has accepted tax agreement so complete and enabled:false is returned' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!
    @w.approve_background_check!
    @w.accept_tax_agreement!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['tax_agreements']['status']).to eq 'complete'
    expect(json['application']['tax_agreements']['enabled']).to eq false
  end

  scenario 'washer has not completed stripe direct deposit setup so incomplete and enabled:true is returned' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!
    @w.approve_background_check!
    @w.accept_tax_agreement!

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['direct_deposits']['status']).to eq 'incomplete'
    expect(json['application']['direct_deposits']['enabled']).to eq true
  end

  scenario 'washer has completed stripe direct deposit setup' do
    @w.complete_app_intro!
    @w.accept_tos!
    @w.complete_eligibility_application!
    @w.complete_eligibility_application!
    @w.mark_background_check_submitted!
    @w.approve_background_check!
    @w.accept_tax_agreement!
    @w.create_stripe_account!
    # stubs stripe account charges enabled check
    allow_any_instance_of(Washer).to receive(:valid_stripe_connect_acount?).and_return(true)

    get '/api/v1/washers/activations/application_statuses', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 200
    expect(json['application']['washer']['full_name']).to eq @w.full_name.upcase
    expect(json['application']['washer']['email']).to eq @w.email
    expect(json['application']['direct_deposits']['status']).to eq 'complete'
    expect(json['application']['direct_deposits']['enabled']).to eq false
  end
end