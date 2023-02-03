require 'rails_helper'
require 'offer_helper'
RSpec.describe SmsAlertUntrackedWorker, type: :worker do
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    # @w.update(phone: '5624816883')
    create_open_offers(1)

    @worker = SmsAlertUntrackedWorker
  end
  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'new order is created (offer dropped), washers are alerted with an sms' do
    @new_order.alert_washers_in_region!
  end

  scenario 'sms is sent via direct call to sidekiq:worker' do
    @worker.perform_async(@w.phone, 'This is a test ok?')
  end
end
