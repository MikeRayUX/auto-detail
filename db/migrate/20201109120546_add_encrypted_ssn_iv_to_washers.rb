class AddEncryptedSsnIvToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :encrypted_ssn_iv, :string, unique: true
  end
end
