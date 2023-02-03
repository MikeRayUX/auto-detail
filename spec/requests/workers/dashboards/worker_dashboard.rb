# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Worker dashboard', type: :request do
  before(:all) do
		DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)
    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))

    @region_pricing = create(:region_pricing)
    @area = create(:coverage_area)
    create(:worker_account_creation_code)

    @worker = create(:worker, :with_region)
  end

  scenario 'worker can log in and view their dashboard' do
    sign_in @worker
    get workers_dashboards_open_appointments_path


    expect(response.body).to match('There are no upcoming pickups currently. Check back later.')
  end

  scenario 'worker can view an upcoming appointment in their dashboard' do
    # new_customer_creates_an_order(@valid_token = 'tok_visa')
    @order = @user.orders.create(attributes_for(:order).merge(
      full_address: @address.full_address,
      routable_address: @address.address
      ))

    sign_in @worker

    get workers_dashboards_open_appointments_path
    expect(response.body).to match(@order.reference_code)
  end
end
