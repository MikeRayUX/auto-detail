# frozen_string_literal: true

# Preview all emails at http://localhost:3001/rails/mailers/users/new_user
class Users::NewUserPreview < ActionMailer::Preview
  def send_email
    @user = User.new(
      full_name: Faker::Name.name,
      email: Faker::Internet.email,
      phone: '3216549879',
      password: 'password',
      password_confirmation: 'password'
    )

    Users::NewUserMailer.send_email(
      @user
    )
  end
end
