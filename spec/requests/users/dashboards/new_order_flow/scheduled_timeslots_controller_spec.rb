require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'users/dashboards/new_order_flow/scheduled_timeslots_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @user = create(:user, :with_active_subscription)
    sign_in @user

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
      region_id: @region.id
    ))

    @address = @user.build_address(attributes_for(:address))
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  # INDEX START
  scenario 'gets available dates & times starting tomorrow' do
    get '/users/dashboards/new_order_flow/scheduled_timeslots'

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:dates_for_select]).to be_present
    expect(json[:dates_for_select].length).to eq 5

    json[:dates_for_select].each do |date|
      expect(date[:holiday]).to eq false
    end
  end

  scenario 'one of the days for select is a holiday so it is skipped replacing it with the next available day where a holiday is not present' do
    @holiday = Holiday.create(
      title: 'XMAS',
      date: Date.current + 1.days
    )

    get '/users/dashboards/new_order_flow/scheduled_timeslots'

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:dates_for_select]).to be_present
    expect(json[:dates_for_select].first[:holiday]).to eq true
    expect(json[:dates_for_select].last[:holiday]).to eq false
    is_holiday = 0
    is_not_holiday = 0

    json[:dates_for_select].each do |date|
      if date[:holiday] == true
        is_holiday = is_holiday + 1
      else 
        is_not_holiday = is_not_holiday + 1
      end
    end

    expect(is_holiday).to eq 1
    expect(is_not_holiday).to eq 4
  end
  # INDEX END
end