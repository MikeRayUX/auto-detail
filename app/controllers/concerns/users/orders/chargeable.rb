module Users::Orders::Chargeable
  extend ActiveSupport::Concern

  protected
  def get_subtotal(order, pricing)
    if (order.courier_weight * pricing.price_per_pound) < pricing.minimum_charge
      pricing.minimum_charge
     else
      (((order.courier_weight * pricing.price_per_pound) * 100).round / 100.00).to_d
     end
  end

  def get_tax(subtotal, user)
    (((subtotal * user.tax_rate) * 100).round / 100.00).to_d
  end

  def get_grandtotal(subtotal, tax)
    (([subtotal, tax].sum * 100).round / 100.00).to_d
  end

end