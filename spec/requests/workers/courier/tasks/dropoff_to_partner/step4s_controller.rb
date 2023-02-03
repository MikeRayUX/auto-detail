require 'rails_helper'
require 'order_helper'
RSpec.describe 'drop off to customer step4s controller', type: :request do
  before do
		DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)

    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)


    @new_bags_code = get_new_bags_code
    @bags_collected = rand(1..5)

    @courier_weight = get_random_weight

    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address,
        bags_code: @new_bags_code,
        bags_collected: @bags_collected,
        courier_weight: @courier_weight
    ))

    @partner_location = PartnerLocation.create!(attributes_for(:partner_location))

    @order.mark_recorded_partner_weight(@courier_weight)

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views form to select a partner to dropoff to' do
    get workers_courier_tasks_dropoff_to_partner_step4_path(id: @order.id)

    page = response.body

    expect(page).to include "Where are you dropping off the order?"
    expect(page).to include "Dropping off (#{@order.bags_collected} bags)"
  end

  scenario 'worker makes a partner location selection and the order is marked as received by partner' do
    put workers_courier_tasks_dropoff_to_partner_step4_path, params: {
      id: @order.id,
      partner_location: @partner_location.id
    }

    expect(Order.first.partner_location).to be_present
    expect(Order.first.global_status).to eq('processing')
    expect(Order.first.drop_off_to_partner_status).to eq('dropped_off_to_partner')
    expect(Order.first.dropped_off_to_partner_at).to be_present
    expect(Order.first.dropped_off_to_partner_at.class).to eq(ActiveSupport::TimeWithZone)
    expect(response).to redirect_to redirect_to workers_dashboards_waiting_orders_path
    expect(flash[:notice]).to eq('Dropped off successfully!')
  end

  scenario 'worker does not make a partner location selection and is kicked back' do
    put workers_courier_tasks_dropoff_to_partner_step4_path, params: {
      id: @order.id,
      partner_location: ''
    }

    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step4_path(id: @order.id)
    
    expect(flash[:notice]).to eq('You must select a valid partner to continue')
  end
end
