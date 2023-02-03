class AddFullNameToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :full_name, :string
  end
end
