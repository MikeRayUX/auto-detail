require 'rails_helper'
RSpec.describe 'users/dashboards/settings/updaste_names_controller', type: :request do

	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    
		sign_in @user
	end

	after do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end

	scenario 'user has an address so they can view the update address from' do
		get users_dashboards_settings_update_names_path

    page = response.body
    
    expect(page).to include "Full name"
    expect(page).to include @user.full_name
  end
  
  scenario 'user updates their name' do
    @new_name = 'laskdjfa;lskdkjfaospidf'
		put users_dashboards_settings_update_names_path, params: {
      user: {
        full_name: @new_name
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(@user.full_name).to eq @new_name
    expect(flash[:notice]).to eq "Updated Successfully!"
  end

  scenario 'user enters a blank name and is kicked back' do
    @previous_name = @user.full_name
    @new_name = ''
		put users_dashboards_settings_update_names_path, params: {
      user: {
        full_name: @new_name
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_update_names_path
    expect(@user.full_name).to eq @previous_name
    expect(flash[:notice]).to eq "Full name can't be blank"
	end

end