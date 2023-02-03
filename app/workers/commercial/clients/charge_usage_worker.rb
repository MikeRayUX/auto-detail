class Commercial::Clients::ChargeUsageWorker
  include Sidekiq::Worker
  # sidekiq_options retry: false

  def perform(client_id)
    @client = Client.find(client_id)

    if @client.has_usage?
      @pickups = @client.commercial_pickups.delivered.unpaid

      @current_usage = @client.current_usage
        
      @subtotal = @pickups.sum(:subtotal)
      @tax = @pickups.sum(:tax)
      @grandtotal = get_grandtotal(@subtotal, @tax)

      @t = @client.transactions.new(
        stripe_customer_id: @client.stripe_customer_id,
        card_brand: @client.card_brand,
        card_exp_month: @client.card_exp_month,
        card_exp_year: @client.card_exp_year,
        card_last4: @client.card_last4,
        customer_email: @client.email,
        region_name: 'n/a',
        tax_rate: 'n/a',
        weight: @current_usage,
        price_per_pound: @client.price_per_pound,
        subtotal: @subtotal,
        tax: @tax,
        grandtotal: @grandtotal,
        start_date: @pickups.first.pick_up_date,
        end_date: @pickups.last.pick_up_date
      )

      @charge = Stripe::Charge.create(
        amount: (@grandtotal * 100).to_i,
        currency: 'usd',
        description: "FreshAndTumble: Commercial Service - Total Weight: #{@current_usage} lbs - Thank you!",
        statement_descriptor: 'Fresh And Tumble LLC',
        customer: @client.stripe_customer_id
      )

      @t.save_succeeded!(@charge)

      @pickups.each do |pickup|
        pickup.mark_paid
      end

      @t.send_payment_success_email!
    else
      p 'theres no usage'
    end
  rescue Stripe::StripeError => e
    puts e
    @t.save_failed!(e)
    @t.send_payment_failure_email!
    @client.pause_service!
  end
end

def get_grandtotal(subtotal, tax)
  (([subtotal, tax].sum * 100).round / 100.00).to_d
end