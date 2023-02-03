class AddOtpSecretKeyToAllUsers < ActiveRecord::Migration[5.2]
  def change
    User.find_each { |user| user.update_attribute(:otp_secret_key, User.otp_random_secret) }
  end
end
