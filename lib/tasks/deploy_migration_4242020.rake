namespace :migration do
  desc 'add minimum charge from region_pricing, store order weight and region pricing on all existing transactions (PRODUCTION MIGRATION 4/24/2020'

  task deploy_4242020: :environment do

    ActiveRecord::Base.transaction do
      RegionPricing.first.update_attribute(:minimum_charge, 25)

      @transactions = Transaction.all

      if @transactions.any?
        @transactions.each do |t|
          p "transaction_id: #{t.id} attempting to update"
          @order = t.order
          if t.update_attributes(
            weight: @order.final_weight, 
            price_per_pound: @order.region_pricing.price_per_pound,
            wash_hours_saved: @order.wash_hours_saved
          )
          p "transaction_id: #{t.id} updated_successfully!"
          else
            p "#{t.id} failed!"
            p t.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end
      else
        p "No transactions to update"
      end
      

    end

  end
end