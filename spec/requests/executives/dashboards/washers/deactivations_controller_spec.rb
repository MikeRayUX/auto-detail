require 'rails_helper'

RSpec.describe 'executives/dashboards/washers/activations_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @executive = create(:executive)
    sign_in @executive

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @washer = Washer.create!(attributes_for(:washer).merge(region_id: @region.id))

    @address = @washer.create_address!(
      attributes_for(:address).merge(
        region_id: @region.id,
        zipcode: @coverage_area.zipcode
      )
    )

    @washer.initial_activate!
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  # scenario 'no washer id is sent and so the request is kicked back' do
  #   put executives_dashboards_washers_deactivations_path, params: {
  #     id: nil
  #   }

  #   @page = response.body

  #   # response
  #   expect(response).to redirect_to executives_dashboards_washers_washers_path
  #   expect(flash[:notice]).to eq 'Invalid washer please try again'
  # end

  # scenario 'active washer is deactivated successfully' do
  #   put executives_dashboards_washers_deactivations_path, params: {
  #     id: @washer.id
  #   }

  #   @page = response.body

  #   # response
  #   expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
  #   expect(flash[:notice]).to eq 'Washer deactivated. They can no longer sign in to the washer app.'

  #   # washer
  #   @washer.reload
  #   expect(@washer.activated_at).to be_present
  #   expect(@washer.deactivated_at).to be_present
  # end

  # scenario 'washer has already been deactivated and cannot be deactivated again' do
  #   @washer.deactivate!

  #   @washer.reload
  #   @date = @washer.deactivated_at

  #   put executives_dashboards_washers_deactivations_path, params: {
  #     id: @washer.id
  #   }

  #   @page = response.body

  #   # response
  #   expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
  #   expect(flash[:notice]).to eq 'Washer cannot be deactivated. Waher is not deactivatable.'

  #   # washer
  #   expect(@washer.activated_at).to be_present
  #   expect(@washer.deactivated_at).to be_present
  #   expect(@washer.deactivated_at).to eq @date
  # end
end