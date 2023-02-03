# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'executives/dashboards/email_sends_controller', type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  # scenario 'do something' do
    
  # end
  
end