# Preview all emails at http://localhost:3000/rails/mailers/washers/application_received
class Washers::ApplicationReceivedPreview < ActionMailer::Preview

  def send_email
    @washer = Washer.new
    
    Washers::ApplicationReceivedMailer.send_email(@washer)
  end

end
