# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'executives/dashboards/holidays_controller', type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'can create a holiday' do
  end
  
end
