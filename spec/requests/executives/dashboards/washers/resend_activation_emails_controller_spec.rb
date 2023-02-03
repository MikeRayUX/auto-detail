require 'rails_helper'

RSpec.describe 'executives/dashboards/washers/resend_activation_emails_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @executive = create(:executive)
    sign_in @executive

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))


    @washer = Washer.new(attributes_for(:washer).merge(region_id: @region.id))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    
    @address = @washer.create_address!(
      attributes_for(:address).merge(
        region_id: @region.id,
        zipcode: @coverage_area.zipcode
      )
    )

    @washer.initial_activate!
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'no washer id is sent and so the request is kicked back' do
    put executives_dashboards_washers_resend_activation_emails_path, params: {
      id: nil
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washers_path
    expect(flash[:notice]).to eq 'Invalid washer please try again'
  end

  scenario 'washer is activated and not banned so initial activation email is resent and the washer is assigned a new password' do
    @initial_password = @washer.encrypted_password

    put executives_dashboards_washers_resend_activation_emails_path, params: {
      id: @washer.id
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
    expect(flash[:notice]).to eq 'Washer Initial Activation Email Has Been Resent.'


    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    # html email
    expect(@html_email).to include("#{@washer.full_name.capitalize}!")
    expect(@html_email).to include("Your FreshAndTumble.com Washer App Account has been Activated!")
  end

  scenario 'washer is not currently activated so an email is not sent' do
    @washer.deactivate!

    put executives_dashboards_washers_resend_activation_emails_path, params: {
      id: @washer.id
    }

    @page = response.body

    # response
    expect(response).to redirect_to executives_dashboards_washers_washer_path(@washer.id)
    expect(flash[:notice]).to eq 'Email not sent. Washer is not active. You must activate the washer first.'

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 0
  end

end