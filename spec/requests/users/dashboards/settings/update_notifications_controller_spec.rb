require 'rails_helper'

RSpec.describe "users/dashboards/settings/update_notifications_controller", type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    sign_out @user
  end

  scenario "user views the update notifications form" do
    get users_dashboards_settings_update_notifications_path

    page = response.body

    expect(page).to include("Notifications")
  end

  scenario "user disables sms notifications emails only" do
    put users_dashboards_settings_update_notifications_path, params: {
      notifications: {
        sms_enabled: false
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:success]).to eq "Updated Successfully!"
    expect(@user.sms_enabled).to eq false
    expect(@user.promotional_emails).to eq true
  end

  scenario "user disables promotional emails only" do
    put users_dashboards_settings_update_notifications_path, params: {
      notifications: {
        promotional_emails: false
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:success]).to eq "Updated Successfully!"
    expect(@user.promotional_emails).to eq false
    expect(@user.sms_enabled).to eq true
  end

  scenario "user disables both" do
    put users_dashboards_settings_update_notifications_path, params: {
      notifications: {
        sms_enabled: false,
        promotional_emails: false
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:success]).to eq "Updated Successfully!"
    expect(@user.promotional_emails).to eq false
    expect(@user.sms_enabled).to eq false
  end

  scenario "user changes neither" do
    put users_dashboards_settings_update_notifications_path, params: {
      notifications: {
        sms_enabled: true,
        promotional_emails: true
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:success]).to eq "Updated Successfully!"
    expect(@user.promotional_emails).to eq true
    expect(@user.sms_enabled).to eq true
  end
end