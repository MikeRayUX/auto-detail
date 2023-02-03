# Preview all emails at http://localhost:3001/rails/mailers/washers/one_time_password
class Washers::OneTimePasswordPreview < ActionMailer::Preview

  def send_email
    @washer = Washer.new(
      email: Faker::Internet.email,
      password: 'asdfasdf'
    )
    Washers::OneTimePasswordMailer.send_email(@washer)
  end
end
