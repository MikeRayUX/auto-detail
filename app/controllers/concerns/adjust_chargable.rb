module AdjustChargable
  extend ActiveSupport::Concern

  # p "order bag_count: #{@order.bag_count}"
  # p "bags missing: #{@missing_bags}"
  # p "adjusted bag count: #{@new_bag_count}"
  # p "price per bag: $#{@order.bag_price}"
  # p "old subtotal: $#{readable_decimal(@order.subtotal)}"
  # p "new subtotal: $#{readable_decimal(@new_subtotal)}"
  # p "old tax: $#{readable_decimal(@order.tax)}"
  # p "new tax: $#{readable_decimal(@new_tax)}"
  # p "included tip: $#{readable_decimal(@order.tip)}"
  # p "old grandtotal: $#{readable_decimal(@order.grandtotal)}"
  # p "stripe transaction amount: #{@transaction.amount}"
  # p "to refund: $#{readable_decimal(@refund_amount)}"
  # p "stripe refund amount: #{@stripe_refund_amount}"
  # p "left over: $#{readable_decimal(@order.grandtotal - @refund_amount)}"
  # p "new grandtotal: $#{readable_decimal(@new_grandtotal)}"
  # p "pmt processing fee: $#{readable_decimal(@order.pmt_processing_fee)} (#{readable_decimal(@order.grandtotal)} * 0.029 + 0.3)"
  # # p "new pmt processing fee: $#{readable_decimal(@new_pmt_processing_fee)} (#{readable_decimal(@new_grandtotal)} * 0.29% + 0.3"
  # p "old washer pay: $#{readable_decimal(@order.washer_pay)}"
  # p "new washer pay: $#{readable_decimal(@new_washer_pay)}"
  # p "old washer final pay: $#{readable_decimal(@order.washer_final_pay)}"
  # p "new washer final pay: $#{readable_decimal(@new_washer_final_pay)}"
  # p "new washer payout desc: #{@new_washer_payout_desc}"
  # p "old profit: $#{readable_decimal(@order.profit)}"
  # p "new profit: $#{readable_decimal(@new_profit)}"

  # p readable_decimal(@new_grandtotal - @order.pmt_processing_fee - @new_tax - @new_washer_final_pay)

  def adjust_charge_with_bag_count(new_bag_count, order)
    @region = order.region
    @new_subtotal = NewOrder.calc_subtotal(
      new_bag_count,
      order.bag_price
    )

    @new_tax = NewOrder.calc_tax(
      @new_subtotal,
      order.tax_rate
    )

    @tip = order.tip
    
    @new_grandtotal = NewOrder.calc_grandtotal(
      @new_subtotal,
      @new_tax,
      @tip
    )

    @refund_amount = order.grandtotal - @new_grandtotal 

    @new_washer_pay = NewOrder.calc_washer_pay(
      @new_subtotal,
      @region.washer_pay_percentage
    )

    @new_washer_final_pay = NewOrder.calc_washer_final_pay(
      @new_subtotal,
      @region.washer_pay_percentage,
      @tip
    )

    @new_washer_payout_desc = "Adjusted: #{NewOrder.new_payout_desc(@order.tip, @new_washer_final_pay)}"

    @new_profit = NewOrder.calc_profit(
      @new_subtotal,
      @new_washer_pay,
      @order.pmt_processing_fee
    )

    order.update(
      bag_count: new_bag_count,
      subtotal: @new_subtotal,
      tax: @new_tax,
      grandtotal: @new_grandtotal,
      washer_pay: @new_washer_pay,
      washer_final_pay: @new_washer_final_pay,
      payout_desc: @new_washer_payout_desc,
      profit: @new_profit
    )

    @refund_amount
  end

end