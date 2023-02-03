# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User cancels their account', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    @user = User.create!(attributes_for(:user))
    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    sign_out @user
  end

  scenario "user views the cancel accounts questionaire" do
    get new_users_dashboards_settings_cancel_accounts_path

    expect(response.body).to include("We're sad to see you go!")
    expect(response.body).to include("Before you cancel, please let us know why you're leaving.")
  end

  scenario "user makes a selection and cancels their account" do
    @answer_selection = ['too_expensive', 'poor_service', 'takes_too_long', 'something_else'].sample
    post users_dashboards_settings_cancel_accounts_path, params: {
      questionaire: {
        subject: 'account_cancellation',
        answer_selection: @answer_selection,
      }
    }

    expect(response).to redirect_to signin_path

    expect(@user.deleted_at).to be_present
    expect(response).to redirect_to signin_path
    expect(flash[:alert]).to eq('Your account has been cancelled.')
  end

  scenario "user doesn't make a selection so a questionaire is not created and their account is canceled anyway" do
    post users_dashboards_settings_cancel_accounts_path, params: {
      questionaire: {
        subject: '',
        answer_selection: '',
        elaboration: ''
      }
    }

    expect(response).to redirect_to signin_path

    expect(@user.deleted_at).to be_present
    expect(response).to redirect_to signin_path
    expect(flash[:alert]).to eq('Your account has been cancelled.')
    expect(@user.questionaires.none?).to eq true
  end

  scenario "user cancelles their account and now cannot log back in" do
    @answer_selection = ['too_expensive', 'poor_service', 'takes_too_long', 'something_else'].sample
    post users_dashboards_settings_cancel_accounts_path, params: {
      questionaire: {
        subject: 'account_cancellation',
        answer_selection: @answer_selection,
      }
    }

    post user_session_path, params: {
      user: {
        email: @user.email,
        passowrd: 'password'
      }
    }

    expect(response.body).to redirect_to new_user_session_path
    expect(flash[:alert]).to eq('Sorry, this account has been cancelled.')
  end
end
