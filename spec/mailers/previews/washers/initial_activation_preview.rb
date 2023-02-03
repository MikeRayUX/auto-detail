# Preview all emails at http://localhost:3001/rails/mailers/washers/initial_activation
class Washers::InitialActivationPreview < ActionMailer::Preview
  def send_email
    @washer = Washer.new(
      email: Faker::Internet.email,
      first_name: Faker::Name.first_name,
      middle_name: Faker::Name.middle_name,
      phone: '2061233234',
      last_name: Faker::Name.last_name,
      date_of_birth: Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d'),
      ssn: "#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}",
      password: 'password',
      password_confirmation: 'password',
    )

    @washer.region = Region.new(area: 'Seattle')

    @temp_password = Devise.friendly_token.first(6)

    Washers::InitialActivationMailer.send_email(@washer, @temp_password)
  end
end
