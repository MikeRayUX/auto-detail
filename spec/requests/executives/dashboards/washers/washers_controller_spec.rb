require 'rails_helper'

RSpec.describe 'executives/dashboards/washers/washers_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @executive = create(:executive)
    sign_in @executive

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    rand(1..25).times do |num|
      @washer = Washer.create!(attributes_for(:washer).merge(region_id: @region.id))
      @washer.update(email: "#{@washer.email}-#{num}")

      @address = @washer.create_address!(
        attributes_for(:address).merge(
          region_id: @region.id,
          zipcode: @coverage_area.zipcode
        )
      )
    end
   
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

end