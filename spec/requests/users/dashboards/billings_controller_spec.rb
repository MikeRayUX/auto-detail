require 'rails_helper'
RSpec.describe 'users/dashboards/billings_controller', type: :request do
	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)

		@user = create(:user, :with_invalid_stripe)
		@pricing = create(:region_pricing)
		@address = @user.create_address!(attributes_for(:address))
		@order = @user.orders.create!(attributes_for(:order).merge(
			full_address: @address.full_address,
			routable_address: @address.address
		))
		sign_in @user
	end

	after do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end

	scenario 'user does not have any transactions and sees a no transactions to show message' do
		get users_dashboards_billings_path

		page = response.body
		expect(page).to include("There's nothing here yet.")
		expect(page).to include("VISA...4242 expires 04/24")
	end

	scenario 'user does not have a payment method and so none is shown' do
		@user.update_attribute(:stripe_customer_id, nil)
		get users_dashboards_billings_path

		page = response.body
		expect(page).to include("There's nothing here yet.")
		expect(page).to_not include("VISA...4242 expires 05/2020")
	end

	scenario 'user has a transaction and it is shown as well as their payment method' do
		@transaction = @user.transactions.create!(attributes_for(:transaction, :paid).merge(
			customer_email: @user.email,
			price_per_pound: @pricing.price_per_pound,
			weight: rand(10..50)
		))
		get users_dashboards_billings_path

		page = response.body

		expect(page).to include("#{@user.card_brand.upcase} ending in #{@user.card_last4}")
		expect(page).to include(@transaction.readable_created_at)
		expect(page).to include(@transaction.order_reference_code)
		expect(page).to include(@transaction.readable_grandtotal)
	end

	scenario 'shows readable paid status of transaction' do
		@transaction = @user.transactions.create!(attributes_for(:transaction, :paid).merge(
			customer_email: @user.email,
			price_per_pound: @pricing.price_per_pound,
			weight: rand(10..50)
		))

		get users_dashboards_billings_path

		page = response.body

		expect(page).to include('PAID')
	end

	scenario 'shows readable failed paid status of transaction' do
		@transaction = @user.transactions.create!(attributes_for(:transaction, :paid).merge(
			customer_email: @user.email,
			price_per_pound: @pricing.price_per_pound,
			weight: rand(10..50),
			paid: 'failed'
		))

		get users_dashboards_billings_path

		page = response.body

		expect(page).to include('FAILED')
	end

	scenario 'shows readable refunded paid status of transaction' do
		@transaction = @user.transactions.create!(attributes_for(:transaction, :paid).merge(
			customer_email: @user.email,
			price_per_pound: @pricing.price_per_pound,
			weight: rand(10..50),
			paid: 'refunded'
		))


		get users_dashboards_billings_path

		page = response.body

		expect(page).to include('REFUNDED')
	end

end