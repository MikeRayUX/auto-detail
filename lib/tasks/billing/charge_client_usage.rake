namespace :billing do
  desc "creates charge worker jobs for each eligible client"
  task charge_client_usage: :environment do 
    p 'charging all current clients'
    if Date.current.saturday?
      @clients = Client.active

      if @clients.any?
        @clients.each do |c|
          if c.has_usage?
            c.charge_usage!
          else
            p 'client has no usage'
          end
        end
      else
        p 'there are no clients to charge'
      end
    end
  end
end