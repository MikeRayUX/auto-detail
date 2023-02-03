class AddSsnToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :secure_ssn, :string
  end
end
