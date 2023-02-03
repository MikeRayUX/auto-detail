def setup_activated_washer_spec
  @region = create(:region, :open_washer_capacity)

  @user = create(:user, :with_payment_method)
  @address = @user.build_address(attributes_for(:address).merge(region_id: @region.id))
  @address.geocode
  @address.save

  @w = Washer.create!(attributes_for(:washer, :activated).merge(region_id: @region.id))
  @auth = JsonWebToken.encode(sub: @w.email)
end

def setup_washer
  @w = Washer.create!(attributes_for(:washer, :activated).merge(region_id: @region.id))
  @w.go_online
  @w.refresh_online_status
  @auth = JsonWebToken.encode(sub: @w.email)
end

def setup_payoutable_washer_spec
  @region = create(:region, :open_washer_capacity)

  @user = create(:user, :with_payment_method)
  @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))

  @w = Washer.create!(attributes_for(:washer, :payoutable).merge(region_id: @region.id))
  @w.go_online
  @w.refresh_online_status
  @auth = JsonWebToken.encode(sub: @w.email)
end

def create_open_offers(count)
  @count = count
  
  @count.times do 
    @bag_count = rand(2..4)
    # @bag_count = 10
    @price_per_bag = format('%.2f', @region.price_per_bag)
    @subtotal = NewOrder.calc_subtotal(@bag_count, @region.price_per_bag)
    @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
    @tip = NewOrder::TIP_OPTIONS.sample
    # @tip = 0
    @grandtotal = NewOrder.calc_grandtotal(@subtotal, @tax, @tip)
    @washer_ppb = NewOrder.calc_washer_ppb(@subtotal, @region.washer_pay_percentage, @bag_count)
    @washer_pay = NewOrder.calc_washer_pay(@subtotal, @region.washer_pay_percentage)
    @washer_final_pay = NewOrder.calc_washer_final_pay(@subtotal, @region.washer_pay_percentage, @tip)

    @pmt_processing_fee = NewOrder.calc_processing_fee(@grandtotal)
    @profit = NewOrder.calc_profit(@subtotal, @washer_pay, @pmt_processing_fee)

    if @tip > 0
      @payout_desc = "$#{readable_decimal(@washer_final_pay)} includes $#{readable_decimal(@tip)} tip"
    else
      @payout_desc = "$#{readable_decimal(@washer_final_pay)}"
    end
   
    @user.new_orders.create!(
      attributes_for(:new_order, :open_offer).merge(
        ref_code: SecureRandom.hex(5),
        est_pickup_by: NewOrder.gen_pickup_estimate,
        pickup_type: 'asap',
        bag_count: @bag_count,
        bag_price: @region.price_per_bag,
        subtotal: @subtotal,
        tax: @tax,
        tip: @tip,
        pmt_processing_fee: @pmt_processing_fee,
        washer_ppb: @washer_ppb,
        washer_pay_percentage: @region.washer_pay_percentage,
        washer_final_pay: @washer_final_pay,
        payout_desc: @payout_desc,
        grandtotal: @grandtotal,
        profit: @profit,
        tax_rate: @region.tax_rate,
        washer_pay: @washer_pay,
        failed_pickup_fee: @region.failed_pickup_fee,
        region_id: @user.address.region.id,
        address: @address.address,
        zipcode: @address.zipcode,
        unit_number: @address.unit_number,
        directions: @address.pick_up_directions,
        full_address: @address.full_address,
        address_lat: @address.latitude,
        address_lng: @address.longitude
    ))
  end

  if count == 1
    @new_order = NewOrder.first
  end
end

def create_scheduled_open_offers(count)
    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    @pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")

    @count = count
  
    @count.times do 
      @bag_count = rand(1..6)
      @price_per_bag = format('%.2f', @region.price_per_bag)
      @subtotal = NewOrder.calc_subtotal(@bag_count, @region.price_per_bag)
      @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
      @tip = NewOrder::TIP_OPTIONS.sample
      @grandtotal = NewOrder.calc_grandtotal(@subtotal, @tax, @tip)
      @washer_ppb = NewOrder.calc_washer_ppb(@subtotal, @region.washer_pay_percentage, @bag_count)
      @washer_pay = NewOrder.calc_washer_pay(@subtotal, @region.washer_pay_percentage)
      @washer_final_pay = NewOrder.calc_washer_final_pay(@subtotal, @region.washer_pay_percentage, @tip)
      @pmt_processing_fee = NewOrder.calc_processing_fee(@grandtotal)
      @profit = NewOrder.calc_profit(@subtotal, @washer_pay, @pmt_processing_fee)
  
      if @tip > 0
        @payout_desc = "$#{readable_decimal(@washer_final_pay)} includes $#{readable_decimal(@tip)} tip"
      else
        @payout_desc = "$#{readable_decimal(@washer_final_pay)}"
      end
     
      @user.new_orders.create!(
        attributes_for(:new_order, :open_offer).merge(
          ref_code: SecureRandom.hex(5),
          pickup_type: 'scheduled',
          accept_by: @pickup_date,
          est_delivery: @pickup_date + 1.days,
          est_pickup_by: @pickup_date,
          bag_count: @bag_count,
          bag_price: @region.price_per_bag,
          subtotal: @subtotal,
          tax: @tax,
          tip: @tip,
          washer_ppb: @washer_ppb,
          washer_pay_percentage: @region.washer_pay_percentage,
          washer_final_pay: @washer_final_pay,
          payout_desc: @payout_desc,
          grandtotal: @grandtotal,
          pmt_processing_fee: @pmt_processing_fee,
          profit: @profit,
          tax_rate: @region.tax_rate,
          washer_pay: @washer_pay,
          failed_pickup_fee: @region.failed_pickup_fee,
          region_id: @user.address.region.id,
          address: @address.address,
          zipcode: @address.zipcode,
          unit_number: @address.unit_number,
          directions: @address.pick_up_directions,
          full_address: @address.full_address,
          address_lat: @address.latitude,
          address_lng: @address.longitude
      ))
    end
  
    if count == 1
      @new_order = NewOrder.first
    end
end

def charge_new_order!(user, new_order)
  @charge = Stripe::Charge.create(
    amount: (new_order.grandtotal * 100).to_i,
    currency: 'usd',
    description: "FRESHANDTUMBLE.COM Order # #{new_order.ref_code}",
    statement_descriptor: 'FRESH AND TUMBLE LLC',
    customer: user.stripe_customer_id
  )
  new_order.update(stripe_charge_id: @charge.id )
end 

def readable_decimal(attribute)
  "#{format('%.2f', attribute)}"
end

SAMPLE_DELIVERY_PHOTO_BASE64 = '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'