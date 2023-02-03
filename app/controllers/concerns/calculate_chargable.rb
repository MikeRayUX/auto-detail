# frozen_string_literal: true

module CalculateChargable
  extend ActiveSupport::Concern

  def build_with_charge
    @bag_count = new_order_params[:bag_count].to_i

    @subtotal = NewOrder.calc_subtotal(
      @bag_count, 
      @region.price_per_bag
    )

    @tax = NewOrder.calc_tax(
      @subtotal, 
      @region.tax_rate
    )

    @tip = new_order_params[:tip].to_i

    @grandtotal = NewOrder.calc_grandtotal(
      @subtotal, 
      @tax, 
      @tip
    )

    @washer_ppb = NewOrder.calc_washer_ppb(
      @subtotal, 
      @region.washer_pay_percentage, 
      @bag_count
    )

    @washer_pay = NewOrder.calc_washer_pay(
      @subtotal, 
      @region.washer_pay_percentage
    )

    @washer_final_pay = NewOrder.calc_washer_final_pay(
      @subtotal, 
      @region.washer_pay_percentage, 
      @tip
    )

    @pmt_processing_fee = NewOrder.calc_processing_fee(@grandtotal)

    @profit = NewOrder.calc_profit(
      @subtotal, 
      @washer_pay,
      @pmt_processing_fee
    )

    @payout_desc = NewOrder.new_payout_desc(
      @tip, 
      @washer_final_pay
    )

    @order = current_user.new_orders.new(new_order_params.merge(
      bag_price: @region.price_per_bag,
      region_id: @region.id,
      ref_code: SecureRandom.hex(5),
      est_pickup_by: NewOrder.gen_pickup_estimate,
      est_delivery: DateTime.current + 24.hours,
      accept_by: DateTime.current + NewOrder::ACCEPT_LIMIT,
      directions: @address.pick_up_directions,
      subtotal: @subtotal,
      tax: @tax,
      tip: @tip,
      washer_ppb: @washer_ppb,
      washer_pay: @washer_pay,
      failed_pickup_fee: @region.failed_pickup_fee,
      washer_final_pay: @washer_final_pay,
      payout_desc: @payout_desc,
      grandtotal: @grandtotal,
      pmt_processing_fee: @pmt_processing_fee,
      profit: @profit,
      tax_rate: @region.tax_rate,
      washer_pay_percentage: @region.washer_pay_percentage,
      address: @address.address,
      zipcode: @address.zipcode,
      unit_number: @address.unit_number,
      full_address: @address.full_address,
      address_lat: @address.latitude,
      address_lng: @address.longitude,
    ))

    @order
  end
  
end
