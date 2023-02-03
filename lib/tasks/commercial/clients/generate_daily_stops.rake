namespace :clients do
  desc "generates today's commercial client stops for all commercial clients (if any)"
  task generate_daily_stops: :environment do 
    Commercial::Clients::GenerateDailyStopsWorker.perform_async 
  end
end