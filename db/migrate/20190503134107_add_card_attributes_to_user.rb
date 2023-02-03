# frozen_string_literal: true

class AddCardAttributesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_brand, :string
    add_column :users, :card_exp_month, :string
    add_column :users, :card_exp_year, :string
    add_column :users, :card_last4, :string
  end
end
