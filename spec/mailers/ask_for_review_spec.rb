require "rails_helper"

RSpec.describe AskForReviewMailer, type: :mailer do
	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
		
		@user = create(:user)
		@address = @user.create_address!(attributes_for(:address))
	end

	after do
		ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
	end

	scenario 'user has no orders so the email is not sent' do

		AskForReviewMailer.send_email(@user)
		expect(ActionMailer::Base.deliveries.count).to eq 0
	end

	scenario 'user has an order and hasnt left a review yet so the email is sent' do
		@order = @user.orders.create(attributes_for(:order).merge(
			full_address: @address.full_address,
			routable_address: @address.address,
			global_status: 'delivered'
		))

		@user.request_business_review!
		expect(ActionMailer::Base.deliveries.count).to eq 1
	end

	scenario 'user has orders but has promotional emails disabled so an email is not sent' do
		@order = @user.orders.create(attributes_for(:order).merge(
			full_address: @address.full_address,
			routable_address: @address.address
		))

		@user.update_attribute(:promotional_emails, false)
		@user.request_business_review!

		expect(ActionMailer::Base.deliveries.count).to eq 0
	end

	scenario 'user has already left a review so the requeset is not sent' do
		@order = @user.orders.create(attributes_for(:order).merge(
			full_address: @address.full_address,
			routable_address: @address.address
		))

		@user.update_attribute(:business_review_left, true)
		@user.request_business_review!

		expect(ActionMailer::Base.deliveries.count).to eq 0
	end

end
