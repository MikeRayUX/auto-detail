require 'rails_helper'

RSpec.describe 'static pages contact customers controller spec', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @region = create(:region)
    @worker = create(:worker, :with_region)

    @email = Faker::Internet.email
    @body = "This is a test"
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  # scenario 'guest can view the contact page form' do
  #   get contactus_path

  #   expect(response.body).to include('Questions?')
  # end

  # scenario 'guest can submit a new support_ticket and has completed the captcha' do
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: @email,
  #     body: @body,
  #    },
  #     "g-recaptcha-response": 'asodijoasjdfoijasd'
  #   }

  #   p flash
 
  #   expect(response).to redirect_to static_pages_contact_pages_path

  #   # expect(SupportTicket.count).to eq(1)
  #   # expect(SupportTicket.first.customer_email).to eq(@email)
  #   # expect(SupportTicket.first.concern).to eq('general_inquiry')
  #   # expect(SupportTicket.first.body).to eq(@body)
  # end


  # scenario "guest doesn't provide an email is shown an error" do
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: '',
  #     body: @body
  #    }
  #   }

  #   expect(SupportTicket.count).to eq(0)
  #   expect(response).to redirect_to contactus_path
  #   expect(flash[:error]).to be_present
  # end

  # scenario "guest doesn't provide an invalid email is shown an error" do
  #   @invalid_email = 'asdpfjasdf'
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: @invalid_email,
  #     body: @body
  #    }
  #   }

  #   expect(SupportTicket.count).to eq(0)
  #   expect(response).to redirect_to contactus_path
  #   expect(flash[:error]).to be_present
  # end

  # scenario "guest doesn't provide a message body and is shown an error" do
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: @email,
  #     body: ''
  #    }
  #   }

  #   expect(SupportTicket.count).to eq(0)
  #   expect(response).to redirect_to contactus_path
  #   expect(flash[:error]).to be_present
  # end


  # scenario "guest doesn't provides a message that is too long and is kicked back" do
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: @email,
  #     body: 'a' * 1001
  #    }
  #   }

  #   expect(SupportTicket.count).to eq(0)
  #   expect(response).to redirect_to contactus_path
  #   expect(flash[:error]).to be_present
  # end

  # scenario 'guest can submit a new support_ticket and views the message received page' do
  #   post static_pages_contact_pages_path, params: {
  #    support_ticket: {
  #     customer_email: @email,
  #     body: @body
  #    }
  #   }
    
  #   follow_redirect!

  #   page = response.body

  #   expect(page).to include("Our support team has received your message.")
  #   expect(page).to include("Thank you and have a great day!")
  # end
  
end