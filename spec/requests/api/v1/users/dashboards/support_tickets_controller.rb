require 'rails_helper'

RSpec.describe 'api/v1/users/dashboards/support_tickets_controller', type: :request do
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

    @auth_token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'user is not logged in' do
    post '/api/v1/users/dashboards/support_tickets', params: {
      ticket: {
        option: @order.reference_code,
        body: 'Someone lost my order!',
      }
    },
    headers: {
      Authorization: 'asdfasdfasfd'
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user creates a support ticket successfully' do
    post '/api/v1/users/dashboards/support_tickets', params: {
      ticket: {
        body: 'Someone lost my order!',
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 201
    expect(json[:message]).to eq 'ticket_created'
    expect(json[:feedback]).to eq "Your message has been received. Please allow up to 48 hours to receive a response. You will receive a reply at your email: #{@user.email}. If you don't hear back soon, please check your spam folder"
    # ticket
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(SupportTicket.first.user.email).to eq @user.email
    expect(SupportTicket.first.concern).to eq('customer_app')
  end

  scenario 'user tries to create an invalid support ticket' do
    post '/api/v1/users/dashboards/support_tickets', params: {
      ticket: {
        body: '',
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'ticket_invalid'
    expect(json[:errors]).to be_present
    # ticket
    expect(SupportTicket.count).to eq 0
  end
end