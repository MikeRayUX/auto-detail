class AddOtpSecretKeyToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :otp_secret_key, :string
  end
end
