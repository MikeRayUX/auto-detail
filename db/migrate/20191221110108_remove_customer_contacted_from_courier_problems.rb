class RemoveCustomerContactedFromCourierProblems < ActiveRecord::Migration[5.2]
  def change
    remove_column :courier_problems, :customer_contacted
  end
end
