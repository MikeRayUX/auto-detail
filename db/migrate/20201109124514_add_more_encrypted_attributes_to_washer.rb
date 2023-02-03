class AddMoreEncryptedAttributesToWasher < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :date_of_birth
    add_column :washers, :encrypted_date_of_birth, :string
    add_column :washers, :encrypted_date_of_birth_iv, :string, unique: true

    remove_column :washers, :phone
    add_column :washers, :encrypted_phone, :string
    add_column :washers, :encrypted_phone_iv, :string, unique: true
  end
end
