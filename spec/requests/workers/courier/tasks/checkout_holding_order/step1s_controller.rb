# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'checkout holding order controller step1s', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)
    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views the customers order information and address for traveling to customer to pickup order' do
  end
end
