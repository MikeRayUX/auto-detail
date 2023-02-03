class CreateSubscription < ActiveRecord::Migration[5.2]
  def change
    # washers migration
    ActiveRecord::Base.transaction do
      @subscription = Subscription.new(
        price: 9.99,
        name: 'Tumble Subscription',
        stripe_product_id: 'prod_IiTXwKVbR5gqqg',
        stripe_price_id: 'price_1I72aUIhRzEonUQK2o8t2G8t'
      )

      if @subscription.save
        p "Subscription created SUCCESSFULLY!"
      else
        p "Subscription create FAILED ROLLING BACK #{@subscription.errors.full_messages.first}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
