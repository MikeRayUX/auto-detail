# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dashboard homes controller', type: :request do
  before do
    @user = create(:user)
    sign_in @user
  end

  after do
    sign_out @user
  end

  scenario 'user can view the start pickup notice in their dashboard' do
    get users_dashboards_homes_path

    expect(response.body).to include('START A PICKUP')
  end

  # scenario 'user has not ordered yet and is shown a helpfull message' do
  #   get users_dashboards_homes_path

  #   expect(response.body).to include('Start A Pickup')
  # end

  # scenario 'user has ordered before and is shown a greeting' do
  #   get users_dashboards_homes_path

  #   expect(response.body).to include('Start A Pickup')
  # end
end
