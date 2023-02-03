require 'rails_helper'
RSpec.describe 'users/dashboards/settings/update_addresses_controller', type: :request do

	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)

		@region = create(:region)
		@coverage_area = CoverageArea.create!(
			attributes_for(:coverage_area).merge(
				region_id: @region.id
			)
		)
		@user = create(:user)
		@address = @user.create_address!(attributes_for(:address).merge(region_id: 1))

		sign_in @user
	end

	after do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end

	scenario 'user has an address so they can view the update address from' do
		get users_dashboards_settings_update_addresses_path

		@page = response.body

		expect(@page).to include "Update Your Address"
	end

	scenario 'user does not have an address to update and is kicked back' do
		@user.address.destroy!
		@user.reload

		get users_dashboards_settings_update_addresses_path
		
		expect(flash[:error]).to be_present
		expect(flash[:error]).to eq "You don't have an address to update."
		expect(response).to redirect_to users_dashboards_settings_info_summaries_path
	end

	scenario 'user updates their address with valid info and is within a coverage area so that coverage areas region is attached' do
		@street_address = '123 sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '98168'

		put users_dashboards_settings_update_addresses_path, params: {
			address: {
				street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
			}
		}

		@address = @user.address

		expect(@address.street_address).to eq @street_address
		expect(@address.city).to eq @city
		expect(@address.state). to eq @state
		expect(@address.zipcode).to eq @zipcode
		expect(@address.region_id).to eq @region.id
	end

	scenario 'user updates their address with valid info but the new address is not within a coverage area so the region is removed' do

		@street_address = '123 sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '55555'

		put users_dashboards_settings_update_addresses_path, params: {
			address: {
				street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
			}
		}

		@address = @user.address

		expect(@address.street_address).to eq @street_address
		expect(@address.city).to eq @city
		expect(@address.state). to eq @state
		expect(@address.zipcode).to eq @zipcode
		expect(@address.region_id).to eq nil
	end


	scenario 'user updates their address but also has a delivery that is pending reattempt and so the address of the pending attempt is updated' do
		@street_address = '123 sample sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '98168'

		@order = @user.orders.create!(
			attributes_for(:order).merge(
				full_address: @user.address.full_address,
				routable_address: @user.address.address
			)
		)

		@order.mark_for_reattempt

		put users_dashboards_settings_update_addresses_path, params: {
			address: {
				street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
			}
		}

		@address = @user.address
		@order.reload

		expect(@order.full_address).to eq @address.full_address
		expect(@order.routable_address).to eq @address.address
	end

	scenario 'user updates their address but also has a delivery that is not pending reattempt and so the address of the order is not updated' do
		@street_address = '123 sample sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '98168'

		@order = @user.orders.create!(
			attributes_for(:order).merge(
				full_address: @user.address.full_address,
				routable_address: @user.address.address
			)
		)

		put users_dashboards_settings_update_addresses_path, params: {
			address: {
				street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
			}
		}

		@address = @user.address
		@order.reload

		expect(@order.full_address).to_not eq @address.full_address
		expect(@order.routable_address).to_not eq @address.address
	end

	scenario 'user attempts to update their address with valid info but they dont have an existing address so they are kicked back' do
		@user.address.destroy!
		@user.reload

		@street_address = '123 sample st'
		@city = 'renton'
		@state = 'wa'
		@zipcode = '98168'

		put users_dashboards_settings_update_addresses_path, params: {
			address: {
				street_address: @street_address,
				city: @city,
				state: @state,
				zipcode: @zipcode
			}
		}

		expect(flash[:error]).to be_present
		expect(response).to redirect_to users_dashboards_settings_info_summaries_path
	end

end