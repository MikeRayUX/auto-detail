# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromCustomer::Step4sController < ApplicationController
  include Users::Orders::Chargeable
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]
  before_action :prevent_dublicate_billing!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
		@order = Order.find(params[:id])
    @pricing = @order.region_pricing
    @user = @order.user
    @order.save_courier_weight(params[:weight])

    @subtotal = get_subtotal(@order, @pricing)
    @tax = get_tax(@subtotal, @user)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    @transaction = @user.new_transaction(@order, @pricing, @subtotal, @tax, @grandtotal)

    @charge = Stripe::Charge.create(
      amount: (@grandtotal * 100).to_i,
      currency: 'usd',
      description: "FreshAndTumble: #{@order.reference_code} - Total Weight: #{@order.courier_weight} lbs - Thank you!",
      statement_descriptor: 'Fresh And Tumble LLC',
      customer: @user.stripe_customer_id
    )

    @transaction.save_succeeded!(@charge)
    
    @order.mark_picked_up!
    @order.send_pickup_success_receipt_email!(
      @transaction.id, 
      @order.readable_picked_up_at
    )

    if @order.notifications.picked_up.none?
      @user.send_sms_notification!(
        event = 'order_picked_up',
        order = @order,
        message_body = 'Your Fresh And Tumble order has been picked up!'
      )
    end

    redirect_to workers_dashboards_open_appointments_path, flash: {
      notice: 'Pickup was successful!'
    }

    rescue Stripe::StripeError => error
      @transaction.save_failed!(error)
      
      @order.reject_pickup!
      @order.send_rejected_email!(@transaction.id)

      if @order.notifications.pickup_rejected.none?
        @user.send_sms_notification!(
          event = 'pickup_rejected',
          order = @order,
          message_body = 'Your Fresh And Tumble Order is being returned to you. Please check your email for more info.'
        )
      end

      redirect_to workers_dashboards_open_appointments_path, flash: {
        notice: 'Pickup failed, return to customer'
      }
  end

  private
  def validate_form!
    unless params[:weight].present? && params[:weight].to_i > 0
      redirect_to workers_courier_tasks_pickup_from_customer_step4_path(id: params[:id]), flash: {
        notice: 'You must enter valid weights to continue.'
      }
    end
  end

  def prevent_dublicate_billing!
    unless Order.find(params[:id]).transactions.none?
      redirect_to workers_dashboards_open_appointments_path, flash: {
        notice: 'This has already been submitted'
      }
    end
  end
end
