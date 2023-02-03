# frozen_string_literal: true

class RemoveAttributesFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :detergent_preference
    remove_column :orders, :special_notes

    add_column :orders, :detergent, :string
    add_column :orders, :use_bleach_on_whites, :boolean
    add_column :orders, :wash_temp, :string

    remove_column :users, :stripe_id
  end
end
