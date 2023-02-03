class AddInsuranceAgreementAcceptedAtToWashers < ActiveRecord::Migration[5.2]
  def change
    add_column :washers, :insurance_agreement_accepted_at, :datetime
  end
end
