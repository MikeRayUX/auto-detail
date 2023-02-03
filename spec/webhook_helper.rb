def switch_db(db)
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[db])
end

def let_webhook_finish
  # WAITS FOR WEBHOOK TO PROCESS OTHERWISE THE AFTER DO BLOCK WILL DELETE/CLEAR MODELS BEFORE WEBHOOK IS ABLE TO PROCESS WEBHOOK
  p "#{'*' * rand(1..10)} WAITING FOR WEBHOOK TO FINISH"
  sleep 5.seconds
end

def sleep_with_feedback(seconds)
  seconds.downto(0) do |i|
    p "#{i} seconds left...."
    sleep 1
  end
end