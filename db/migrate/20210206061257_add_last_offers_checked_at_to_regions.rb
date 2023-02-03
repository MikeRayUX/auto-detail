class AddLastOffersCheckedAtToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :last_washer_offer_check, :datetime
  end
end
