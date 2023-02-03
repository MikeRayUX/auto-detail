require 'rails_helper'
require 'order_helper'
RSpec.describe 'users/dashboards/settings/update_emails_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user views the update emails page' do
    get users_dashboards_settings_update_emails_path

    page = response.body

    expect(page).to include("Email")
  end

  scenario "user doesn't have a stripe payment method so a stripe customer is not created or updated but the email is updated" do
    @new_email = Faker::Internet.email

    put users_dashboards_settings_update_emails_path, params: {
      email: {
        email: @new_email
      }
    }

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:notice]).to eq "Updated Successfully!"
    expect(@user.email).to eq @new_email
  end

  scenario "user has a stripe payment method so the stripe email is updated" do
    create_stripe_customer!
    
    # old stripe customer
    @old_stripe_customer = retrieve_stripe_customer(@user)
    expect(@old_stripe_customer[:email]).to eq @user.email

    @new_email = Faker::Internet.email

    put users_dashboards_settings_update_emails_path, params: {
      email: {
        email: @new_email
      }
    }
    
    # updated stripe customer
    @updated_stripe_customer = retrieve_stripe_customer(@user)
    expect(@updated_stripe_customer[:email]).to eq @new_email

    expect(response).to redirect_to users_dashboards_settings_info_summaries_path
    expect(flash[:notice]).to eq "Updated Successfully!"
    expect(@user.email).to eq @new_email
  end

  scenario "user submits the same email as before and the stripe customer email does not change" do
    create_stripe_customer!

    put users_dashboards_settings_update_emails_path, params: {
      email: {
        email: @user.email
      }
    }
    
    # updated stripe customer
    @updated_stripe_customer = retrieve_stripe_customer(@user)
    expect(@updated_stripe_customer[:email]).to eq @user.email
  end

  scenario "user submits an invalid email and is kicked back" do
    create_stripe_customer!

    put users_dashboards_settings_update_emails_path, params: {
      email: {
        email: 'user.email'
      }
    }

    @user.reload

    p @user.email
    
    # updated stripe customer
    @updated_stripe_customer = retrieve_stripe_customer(@user)
    expect(@updated_stripe_customer[:email]).to eq @user.email

    expect(response).to redirect_to users_dashboards_settings_update_emails_path
    expect(flash[:notice]).to eq 'Email is invalid'
  end

end