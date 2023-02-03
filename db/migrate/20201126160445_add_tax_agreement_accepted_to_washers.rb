class AddTaxAgreementAcceptedToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :tax_agreement_accepted_at, :datetime
  end
end
