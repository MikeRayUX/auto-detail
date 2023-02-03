require 'rails_helper'
RSpec.describe SendgridTemplateMailerWorker, type: :worker do
  # ACCESS TEMPLATES AT https://mc.sendgrid.com/dynamic-templates
  
  # NOTE:
  # variables in sendgrid dynamic templates are accessed in the template by using handlebars syntax {{user}} (or any variable you want in the template builder on sendgrid.com 

  before do
    DatabaseCleaner.clean_with(:truncation)
    @sendgrid_email = create(:sendgrid_email)

    @region = create(:region)
    @user = create(:user)

    @washer = Washer.new(attributes_for(:washer, :applied).merge(region_id: @region.id, email: 'bassclefayo@gmail.com'))
    @washer.skip_finalized_washer_attributes = true
    @washer.save

    @worker = SendgridTemplateMailerWorker
    Sidekiq::Testing.inline!
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker is added to jobs array' do
    Sidekiq::Testing.fake!
    @worker.perform_async

    expect(@worker.jobs.size).to eq 1
  end
  
  # SENDS EMAIL IN THE REAL WORLD!! ENABLE ONLY OCCASIONALLY
  # scenario 'email is sent to a single user creating an email send record, the sendgrid_email should have a email_send record and the record should also have a user' do
  #   @worker.perform_async(
  #     @user.id,
  #     'users',
  #     @sendgrid_email.id
  #   )

  #   # SendgridEmail
  #   expect(@sendgrid_email.email_sends.count).to eq 1
  #   # EmailSend
  #   @send = EmailSend.last
  #   expect(@send.sendgrid_email_id).to eq @sendgrid_email.id
  #   expect(@send.status).to eq 'sent'
  #   expect(@send.api_errors).to eq nil
  #   expect(@send.user_id).to eq @user.id
  #   expect(@send.washer_id).to eq nil 
  #   # User
  #   expect(@user.email_sends.count).to eq 1
  #   expect(@user.email_sends.last.sendgrid_email_id).to eq @sendgrid_email.id
  # end

  # # SENDS EMAIL IN THE REAL WORLD!! ENABLE ONLY OCCASIONALLY
  # scenario 'email is sent to a single washer creating an email send record, the sendgrid_email should have a email_send record and the record should also have a washer' do
  #   @worker.perform_async(
  #     @washer.id,
  #     'washers',
  #     @sendgrid_email.id
  #   )

  #   # SendgridEmail
  #   expect(@sendgrid_email.email_sends.count).to eq 1
  #   # EmailSend
  #   @send = EmailSend.last
  #   expect(@send.sendgrid_email_id).to eq @sendgrid_email.id
  #   expect(@send.status).to eq 'sent'
  #   expect(@send.api_errors).to eq nil
  #   expect(@send.washer_id).to eq @washer.id
  #   expect(@send.user_id).to eq nil 
  #   # Washer
  #   expect(@washer.email_sends.count).to eq 1
  #   expect(@washer.email_sends.last.sendgrid_email_id).to eq @sendgrid_email.id
  # end

  scenario 'email is not sent to the user due to an invalid template_id the send is created with api_errors and the staus is set to failed' do
    @sendgrid_email.update(attributes_for(:sendgrid_email, :invalid_template_id))
    @worker.perform_async(
      @user.id,
      'users',
      @sendgrid_email.id
    )

    # SendgridEmail
    expect(@sendgrid_email.email_sends.count).to eq 1
    # EmailSend
    @send = EmailSend.last
    expect(@send.sendgrid_email_id).to eq @sendgrid_email.id
    expect(@send.status).to eq 'failed'
    expect(@send.api_errors).to be_present
    expect(@send.user_id).to eq @user.id
    # User
    expect(@user.email_sends.count).to eq 1
    expect(@user.email_sends.last.sendgrid_email_id).to eq @sendgrid_email.id
  end

  scenario 'email is not sent to the washer due to an invalid template_id the send is created with api_errors and the staus is set to failed' do
    @sendgrid_email.update(attributes_for(:sendgrid_email, :invalid_template_id))
    @worker.perform_async(
      @washer.id,
      'washers',
      @sendgrid_email.id
    )

    # SendgridEmail
    expect(@sendgrid_email.email_sends.count).to eq 1
    # EmailSend
    @send = EmailSend.last
    expect(@send.sendgrid_email_id).to eq @sendgrid_email.id
    expect(@send.status).to eq 'failed'
    expect(@send.api_errors).to be_present
    expect(@send.washer_id).to eq @washer.id
    # Washer
    expect(@washer.email_sends.count).to eq 1
    expect(@washer.email_sends.last.sendgrid_email_id).to eq @sendgrid_email.id
  end

end
