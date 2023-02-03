# Preview all emails at http://localhost:3001/rails/mailers/commercial/billing/payment_receipt
class Commercial::Billing::PaymentReceiptPreview < ActionMailer::Preview

  def send_email
      @client = Client.new(
        name: 'acme salon',
        phone: '5555555555',
        email: 'acmesalon@sample.com',
        special_notes: 'nothing here',
        contact_person: 'adam smith',
        area_of_business: 'nail salon',
        monday: true,
        tuesday: true,
        wednesday: true,
        thursday: true,
        friday: true,
        saturday: true,
        sunday: true,
        pickup_window: 'afternoon',
        price_per_pound: 1.49,
        card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '24',
        card_last4: '4242',
        created_at: DateTime.current
      )
  
      @transaction = @client.transactions.new(
        stripe_customer_id: @client.stripe_customer_id,
        card_brand: @client.card_brand,
        card_exp_month: @client.card_exp_month,
        card_exp_year: @client.card_exp_year,
        card_last4: @client.card_last4,
        customer_email: @client.email,
        region_name: 'seattle',
        tax_rate: 0.101,
        weight: 1124.43,
        price_per_pound: @client.price_per_pound,
        subtotal: 1675.40,
        tax: 169.21,
        grandtotal: 1844.61,
        start_date: Date.current,
        end_date: Date.tomorrow  )
  
        Commercial::Billing::PaymentReceiptMailer.send_email(@transaction)
    end

end
