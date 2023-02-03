require 'rails_helper'

RSpec.describe 'users/dashboards/support_tickets_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @user = User.create!(attributes_for(:user))
    @address = @user.create_address!(attributes_for(:address))
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
      )
    )

    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'user views the suport ticket form' do
    get new_users_dashboards_support_tickets_path

    expect(response.body).to include('How Can We Help?')
  end

  scenario 'user can see their recent order as an option to select in the form' do
    get new_users_dashboards_support_tickets_path

    expect(response.body).to include(@order.support_selectable)
  end

  scenario 'user created an order related support ticket and is successfull' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: @order.reference_code,
        body: 'Someone lost my order!',
      }
    }

    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(SupportTicket.first.user).to be_present
    expect(SupportTicket.first.order).to be_present
    expect(SupportTicket.first.concern).to eq('order_related')
    expect(response).to redirect_to users_dashboards_support_tickets_path
  end

  scenario 'user tries to create an order related support ticket without selecting an order and is kicked back' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: '',
        body: 'Someone lost my order!',
      }
    }

    expect(flash[:errors]).to eq('You must fill out the entire form to continue.')
  end

  scenario 'user selects an order but doesnt include a body so they are kicked back' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: @order.reference_code,
        body: '',
      }
    }

    expect(flash[:errors]).to be_present
    expect(flash[:errors]).to eq('You must fill out the entire form to continue.')
    expect(response).to redirect_to new_users_dashboards_support_tickets_path
  end

  scenario 'user creates a general inquiry support ticket and is successful' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: 'general_inquiry',
        body: 'Someone lost my order!',
      }
    }

    @ticket = SupportTicket.first
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(@ticket.user).to be_present
    expect(@ticket.order).to_not be_present
    expect(@ticket.order_id).to_not be_present
    expect(@ticket.order_reference_code).to_not be_present
    expect(@ticket.pick_up_appointment).to_not be_present
    expect(@ticket.concern).to eq('general_inquiry')
    expect(response).to redirect_to users_dashboards_support_tickets_path
  end

  scenario 'user tries to submit a general inquiry support ticket without a body and is kicked back' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: 'general_inquiry',
        body: '',
      }
    }

    expect(SupportTicket.count).to eq(0)
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(flash[:errors]).to be_present
    expect(response).to redirect_to new_users_dashboards_support_tickets_path
  end

  scenario 'user tries to submit a support ticket without making a selection and is kicked back' do
    post users_dashboards_support_tickets_path, params: {
      ticket: {
        option: '',
        body: 'aosidjfaosdijf',
      }
    }

    expect(SupportTicket.count).to eq(0)
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(flash[:errors]).to be_present
    expect(response).to redirect_to new_users_dashboards_support_tickets_path
  end


end