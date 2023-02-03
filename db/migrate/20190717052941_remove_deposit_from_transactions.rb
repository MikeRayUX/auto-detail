# frozen_string_literal: true

class RemoveDepositFromTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :deposit
  end
end
