class AddPayoutableAsIcToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :payoutable_as_ic, :boolean, default: true
  end
end
