# frozen_string_literal: true

class ChangePaidToEnumOfTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :paid, 'integer USING CAST(paid AS integer)'
  end
end
