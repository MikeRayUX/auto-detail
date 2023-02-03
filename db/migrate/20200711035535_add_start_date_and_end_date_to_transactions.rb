class AddStartDateAndEndDateToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :start_date, :datetime
    add_column :transactions, :end_date, :datetime
  end
end
