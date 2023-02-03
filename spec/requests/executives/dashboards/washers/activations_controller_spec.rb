require 'rails_helper'

RSpec.describe 'executives/dashboards/washers/activations_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @executive = create(:executive)
    sign_in @executive

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @washer = Washer.create!(attributes_for(:washer, :applied).merge(region_id: @region.id))

    @address = @washer.create_address!(
      attributes_for(:address).merge(
        region_id: @region.id,
        zipcode: @coverage_area.zipcode
      )
    )
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'no washer id is sent and so the request is kicked back' do
    put executives_dashboards_washers_activations_path, params: {
      id: nil
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washers_path
    expect(flash[:notice]).to eq 'Invalid washer please try again'
  end

  scenario 'washer is activated for the first time and received an activation email is sent' do
    put executives_dashboards_washers_activations_path, params: {
      id: @washer.id
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
    expect(flash[:notice]).to eq 'Washer Activated & Initial Activation Email Sent.'

    # washer
    @washer.reload
    expect(@washer.activated_at).to be_present

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1

    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body

    # html email
    expect(@html_email).to include(@washer.full_name.capitalize)
    expect(@html_email).to include("Your FreshAndTumble.com Washer App Account has been Activated!")
  end

  scenario 'washer has been previously deactivated and is reactivated allowing them to login' do
    @washer.initial_activate!
    @washer.deactivate!

    put executives_dashboards_washers_activations_path, params: {
      id: @washer.id
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
    expect(flash[:notice]).to eq 'Washer Reactivated, and access to account has been restored.'

    # washer
    @washer.reload
    expect(@washer.activated_at).to be_present
    expect(@washer.deactivated_at).to_not be_present
  end

end