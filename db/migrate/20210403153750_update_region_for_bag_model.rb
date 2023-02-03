class UpdateRegionForBagModel < ActiveRecord::Migration[5.2]
  def change
    # washers migration
    if Region.any?
      ActiveRecord::Base.transaction do
        @region = Region.first
  
        if @region.update_attributes(
          washer_capacity: 1,
          price_per_bag: 24.99,
          washer_pay_percentage: 0.80,
          stripe_tax_rate_id: 'txr_1GCeMaIhRzEonUQKvMvvYCW3',
          max_concurrent_offers: 10,
          failed_pickup_fee: 7,
          business_open: "9:00AM",
          business_close: "8:00PM"
        )
          p "Region updated SUCCESSFULLY!"
        else
          p "Region update FAILED ROLLING BACK"
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
