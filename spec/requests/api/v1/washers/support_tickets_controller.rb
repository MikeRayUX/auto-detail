require 'rails_helper'
require 'offer_helper'

RSpec.describe 'api/v1/washers/sessions_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    
    @region = create(:region)
    @washer = Washer.new(attributes_for(:washer).merge(
      region_id: @region.id
    ))
    @washer.skip_finalized_washer_attributes = true
    @washer.save!
    @address = @washer.create_address!(attributes_for(:address))

    @auth = JsonWebToken.encode(sub: @washer.email)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is authenticated successfully' do
    # before_action :authenticate_washer!

    post '/api/v1/washers/support_tickets',  {
      params: {
        support_ticket: {
          body: 'i need help',
        },
      },
      headers: {
        Authorization: ''
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
    expect(json[:errors]).to eq ['Your session has expired. Please log in to continue.']
  end

  scenario 'support ticket is sent successfully' do
    # before_action :authenticate_washer!

    @body = 'i need help'

    post '/api/v1/washers/support_tickets', {
      params: {
        support_ticket: {
          body: @body
        },
      },
      headers: {
        Authorization: @auth
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    p json

    # response
    expect(json[:code]).to eq 201
    expect(json[:message]).to eq 'support_ticket_sent'
    expect(json[:details]).to eq "Your message has been sent succesffully. You will receive a response at your email: #{@washer.email}"
    # support_ticket
    @t = @washer.support_tickets.last

    expect(@t.concern).to eq 'washer_support'
    expect(@t.customer_email).to eq @washer.email
    expect(@t.body).to eq @body

    expect(@t.user_id).to eq nil
    expect(@t.order_id).to eq nil
  end
end