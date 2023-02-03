# frozen_string_literal: true

module Users::Orders::Orderable
  extend ActiveSupport::Concern

  protected

  def appointment_not_taken?(order)
    if Appointment.where(
      pick_up_date: order.pick_up_date,
      pick_up_time: order.pick_up_time
    ).none?
      true
    else
      order.errors[:base] << "We're sorry, this appointment has already been taken. Please try a different time or date"
      false
    end
  end

  def enough_time_to_pickup?(order, order_params)
    if Time.parse("#{Date.parse(order_params[:pick_up_date]).strftime}, #{order_params[:pick_up_time]}") > 30.minutes.from_now
      true
    else
      order.errors[:base] << "We're sorry, the pickup window for this appointment has already passed. Please try a different time or date"
      false
    end
  end

  # def customer_account_in_good_standing?(user, order)
  #   if user.transactions.where(paid: 'failed').none?
  #     true
  #   else
  #     order.errors[:base] << "Your account has a past due balance and cannot create new orders at this time."
  #     false
  #   end
  # end

end
