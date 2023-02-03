class Commercial::Clients::GenerateDailyStopsWorker
  include Sidekiq::Worker

  def perform()
    p "generating todays commercial client stops if any"
    @active_clients = Client.active
    if @active_clients.any?
      @active_clients.each do |client|
        if client.eligible_for_pickup_today?
          client.addresses.each do |address|
            address.create_pickup_for_today!
          end
        end
      end
    else
      p 'there are no active clients'
    end
  end
end
