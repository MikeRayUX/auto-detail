class AddEncryptedSsnToWashers < ActiveRecord::Migration[5.2]
  def change
    remove_column :washers, :ssn

    add_column :washers, :encrypted_ssn, :string
  end
end
