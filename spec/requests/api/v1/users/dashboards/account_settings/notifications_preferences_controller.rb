# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'api/v1/users/dashboards/account_settings/notifications_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = User.create!(attributes_for(:user))

    @user = User.first

    @token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  # INDEX START
  scenario "user is not logged in" do
    @choice = [true, false]
    @sms_enabled = @choice.sample
    @promotional_emails = @choice.sample

    @user.update_attributes(
      sms_enabled: @sms_enabled,
      promotional_emails: @promotional_emails
    )

    get '/api/v1/users/dashboards/account_settings/notifications_preferences', headers: {
      Authorization: 'asdfasd'
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario "user gets their notification preferences" do
    @choice = [true, false]
    @sms_enabled = @choice.sample
    @promotional_emails = @choice.sample

    @user.update_attributes(
      sms_enabled: @sms_enabled,
      promotional_emails: @promotional_emails
    )

    get '/api/v1/users/dashboards/account_settings/notifications_preferences', headers: {
      Authorization: @token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'preferences_returned'
    expect(json[:sms_enabled]).to eq @sms_enabled
    expect(json[:promotional_emails]).to eq @promotional_emails
    # user
    expect(User.first.sms_enabled).to eq(@sms_enabled)
    expect(User.first.promotional_emails).to eq(@promotional_emails)
  end
  # INDEX END

  scenario "user can update their notification preferences" do
    @choice = [true, false]
    @sms_enabled = @choice.sample
    @promotional_emails = @choice.sample

    put '/api/v1/users/dashboards/account_settings/notifications_preferences/1', 
    params: {
      preference: {
        sms_enabled: @sms_enabled,
        promotional_emails: @promotional_emails
      }
    },
      headers: {
      Authorization: @token
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    # respone
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'updated_successfully'
    # user
    expect(User.first.sms_enabled).to eq(@sms_enabled)
    expect(User.first.promotional_emails).to eq(@promotional_emails)
  end
end
