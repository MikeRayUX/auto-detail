# frozen_string_literal: true

class AddPartnerToOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :addresses, :client_id
  end
end
