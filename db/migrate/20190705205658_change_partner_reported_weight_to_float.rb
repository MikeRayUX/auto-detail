# frozen_string_literal: true

class ChangePartnerReportedWeightToFloat < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :partner_reported_weight, :float
  end
end
