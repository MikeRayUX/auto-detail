require 'rails_helper'
require 'offer_helper'
RSpec.describe SmsNotificationWorker, type: :worker do
	before do
		DatabaseCleaner.clean_with(:truncation)

		setup_activated_washer_spec
		create_open_offers(1)

		@worker = SmsNotificationWorker

    Sidekiq::Testing.inline!
	end

	after do
		DatabaseCleaner.clean_with(:truncation)
	end

	scenario 'sms is enabled | enroute for pickup' do
		@event = 'enroute_to_customer_for_pickup'
		@message_body = "#{@w.abbrev_name} is on their way to you for your laundry pickup"

		@user.send_sms_notification!(@event, @new_order, @message_body)

		@n = Notification.first

		expect(@n.new_order_id).to eq @new_order.id
		expect(@n.notification_method).to eq 'sms'
		expect(@n.event).to eq @event
		expect(@n.sent).to eq true
		expect(@n.sent_at).to be_present
		expect(@n.message_body).to eq @message_body
		expect(@new_order.notifications.where(event: @event).count).to eq 1
	end

	scenario 'user does not have sms enabled so a notification is not sent' do
		@user.update(sms_enabled: false)
		@event = 'enroute_to_customer_for_pickup'
		@message_body = "#{@w.abbrev_name} is on their way to you for your laundry pickup. Please ensure that your bags are accessible for a contactless pickup. Thanks!"

		@user.send_sms_notification!(@event, @new_order, @message_body)

		expect(Notification.count).to eq 0
	end
end
