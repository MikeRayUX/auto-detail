require 'rails_helper'

RSpec.describe 'executives/dashboards/coverage_areas_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @region = create(:region)
    @user = create(:user)

    @executive = create(:executive)
    sign_in @executive

    
    # addresses to be successfully linked to region
    10.times do
      create(:address)
    end

    # outside coverage area
    10.times do
      Address.create(attributes_for(:address).merge(zipcode: '55555'))
    end
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  # CREATE START
  scenario 'a new coverage area is created, and all existing addresses attached to region are reset to ensure that addresses previously outside the region are now inside the region (can make an order)' do
    @coverage_area_to_create = CoverageArea.new(attributes_for(:coverage_area))

    post executives_dashboards_coverage_areas_path, params: {
      coverage_area: {
        region_id: @region.id,
        zipcode: @coverage_area_to_create.zipcode,
        state: @coverage_area_to_create.state,
        county: @coverage_area_to_create.county,
        city: @coverage_area_to_create.city,
      }
    }

    # response
    expect(flash[:notice]).to eq 'Coverage Area Added' 
    expect(response).to redirect_to executives_dashboards_region_path(@region.id)
    # region
    expect(@region.coverage_areas.count).to eq 1
    expect(@region.coverage_areas.first.zipcode).to eq @coverage_area_to_create.zipcode
    expect(@region.addresses.count).to eq 10
    # coverage_area
    expect(CoverageArea.count).to eq 1
    @coverage_area = CoverageArea.first
    expect(@coverage_area.zipcode).to eq @coverage_area_to_create.zipcode
    expect(@coverage_area.state).to eq @coverage_area_to_create.state
    expect(@coverage_area.county).to eq @coverage_area_to_create.county
    expect(@coverage_area.city).to eq @coverage_area_to_create.city
    expect(@coverage_area.region_id).to eq @region.id
    # addresses
    expect(Address.where(region_id: nil).count).to eq 10
  end
  # CREATE END

  # DESTROY START
  scenario 'an existing coverage area is deleted and all existing addresses attached to region are now no longer linked to region of coverage area' do
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    delete executives_dashboards_coverage_area_path(id: @coverage_area.id)

    # response
    expect(flash[:notice]).to eq 'Coverage Area Deleted' 
    expect(response).to redirect_to executives_dashboards_region_path(@region.id)
    # region
    expect(@region.coverage_areas.count).to eq 0
    expect(@region.addresses.count).to eq 0
    # coverage_area
    expect(CoverageArea.count).to eq 0
    # addresses
    expect(Address.where(region_id: nil).count).to eq 20
  end
  # DESTROY END
end