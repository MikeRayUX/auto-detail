# frozen_string_literal: true

class AddPartnerIdToAddress < ActiveRecord::Migration[5.2]
  def change
    add_column :addresses, :partner_id, :integer
    add_index :addresses, :partner_id
  end
end
