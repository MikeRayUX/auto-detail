class AddPhoneToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :phone, :string
  end
end
