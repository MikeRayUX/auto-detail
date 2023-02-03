# frozen_string_literal: true

class AddPartnerAndWorkerToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :partner_id, :integer
    add_index :orders, :partner_id

    add_column :orders, :worker_id, :integer
    add_index :orders, :worker_id
  end
end
