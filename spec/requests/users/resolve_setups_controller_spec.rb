# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'resolve setups controller spec', type: :request do
  before do
		DatabaseCleaner.clean_with(:truncation)
		
		@region = create(:region)
		@coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
			region_id: @region.id
		))

    @password = Faker::Internet.password
    
    @user = create(:user)

    sign_in @user
  end

  scenario "user hasn't completed setup and is redirected to add an address" do
    get users_resolve_setups_path

    expect(response).to redirect_to new_users_resolve_setup_path
	end
	
	scenario 'user has completed setup and is redirected to resolve subscriptions' do
    @user.create_address!(attributes_for(:address))

    get users_resolve_setups_path

    expect(response).to redirect_to new_users_dashboards_new_order_flow_pickups_path
  end

	scenario 'compeletes setup by adding a new address with valid info and is within a coverage area so a region is attached' do
		@street_address = '123 sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '98168'

    post users_resolve_setups_path, params: {
      address: {
        street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
      }
		}
		
		@address = @user.address
    
    expect(response).to redirect_to users_resolve_setups_path
		expect(User.first.address).to be_present

		expect(@address.street_address).to eq @street_address
		expect(@address.city).to eq @city
		expect(@address.state). to eq @state
		expect(@address.zipcode).to eq @zipcode
		expect(@address.region_id).to eq @region.id
	end
	
	scenario 'compeletes setup by adding a new address with valid info but is not within a coverage area so a region is not attached' do
		@street_address = '123 sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '55555'

    post users_resolve_setups_path, params: {
      address: {
        street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
      }
		}
		
		@address = @user.address
    
    expect(response).to redirect_to users_resolve_setups_path
		expect(User.first.address).to be_present

		expect(@address.street_address).to eq @street_address
		expect(@address.city).to eq @city
		expect(@address.state). to eq @state
		expect(@address.zipcode).to eq @zipcode
		expect(@address.region_id).to eq nil
  end

  scenario 'user is kicked back for invalid address info' do
		get users_resolve_setups_path
		
    post users_resolve_setups_path, params: {
      address: {
        street_address: '',
        unit_number: '12A',
        city: 'seattle',
        state: 'wa',
        zipcode: '98168'
      }
    }

    expect(response).to redirect_to users_resolve_setups_path
    expect(flash[:error]).to be_present
    expect(flash[:error]).to eq('Invalid address.')
    expect(Address.count).to eq(0)
  end
  
end
