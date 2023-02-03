class AddEncryptedDriversLicenseNumberToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :encrypted_drivers_license, :string
    add_column :washers, :encrypted_drivers_license_iv, :string, unique: true
  end
end
