# == Schema Information
#
# Table name: new_orders
#
#  id                           :bigint           not null, primary key
#  user_id                      :bigint
#  washer_id                    :bigint
#  region_id                    :bigint
#  ref_code                     :string
#  detergent                    :integer
#  softener                     :integer
#  bag_count                    :integer
#  scheduled                    :datetime
#  picked_up_at                 :datetime
#  delivered_at                 :datetime
#  est_delivery                 :datetime
#  tax_rate                     :float
#  subtotal                     :decimal(12, 2)
#  tax                          :decimal(12, 2)
#  grandtotal                   :decimal(12, 2)
#  tip                          :decimal(12, 2)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  address                      :string
#  unit_number                  :string
#  directions                   :string
#  accept_by                    :datetime
#  accepted_at                  :datetime
#  cancelled_at                 :datetime
#  completed_at                 :datetime
#  stripe_charge_id             :string
#  washer_pay                   :decimal(12, 2)
#  profit                       :decimal(12, 2)
#  zipcode                      :string
#  customer_rating              :integer
#  enroute_for_pickup_at        :datetime
#  arrived_for_pickup_at        :datetime
#  status                       :integer          default("created")
#  full_address                 :string
#  address_lat                  :float
#  address_lng                  :float
#  pickup_type                  :integer
#  bag_codes                    :string
#  wash_notes                   :string
#  washer_final_pay             :decimal(12, 2)
#  washer_ppb                   :decimal(12, 2)
#  stripe_transfer_id           :string
#  stripe_transfer_error        :string
#  payout_desc                  :string
#  readable_delivered_at        :string
#  est_pickup_by                :datetime
#  stripe_refund_id             :string
#  pmt_processing_fee           :decimal(12, 2)
#  washer_adjusted_bag_count_at :datetime
#  refunded_amount              :decimal(12, 2)
#  delivery_location            :integer
#  delivery_photo_base64        :string
#  washer_pay_percentage        :float
#  failed_pickup_fee            :decimal(12, 2)
#  bag_price                    :decimal(12, 2)
#


class NewOrder < ApplicationRecord
  scope :offerable, -> { where(washer_id: nil).where('accept_by > ?', DateTime.current).where(status: 'created').where.not(status: 'cancelled')}
  scope :pending_pickup, -> { where(picked_up_at: nil).where(pickup_type: 'asap')}
  scope :asap_pickups_pending, -> { where(picked_up_at: nil).where(pickup_type: 'asap').where.not(status: 'cancelled')}
  scope :accepted, -> { where.not(accepted_at: nil) } 
  scope :expired, -> { where(washer_id: nil).where('accept_by < ?', DateTime.current)}
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :delivered, -> { where.not(delivered_at: nil) }
  scope :payed_out, -> {where.not(stripe_transfer_id: nil)}
  scope :payout_failed, -> {where.not(stripe_transfer_error: nil)}
  scope :in_progress, -> { where(delivered_at: nil).where.not(status: 'cancelled') }
  scope :asap, -> {where(pickup_type: 'asap')}
  scope :scheduled, -> {where(pickup_type: 'scheduled')}
  scope :newest, -> {order(created_at: :desc)}
  scope :oldest, -> {order(created_at: :asc)}
  scope :refunded, -> {where.not(refunded_amount: nil)}
  # DATES
  scope :today, -> {where(created_at: DateTime.current.all_day)}
  scope :mtd, -> { where(created_at: Date.current.at_beginning_of_month..Date.current.end_of_day)}
  scope :ytd, -> {where(created_at: Date.current.at_beginning_of_year..Date.current.end_of_day)}

  MAX_CONCURRENT_ASAP_OFFERS = 10

  belongs_to :user
  belongs_to :washer, optional: true
  belongs_to :region
  has_many :notifications
  has_many :offer_events

  attr_accessor :skip_finalization_attributes
  attr_accessor :skip_charge_validate

  attr_accessor :pickup_date
  attr_accessor :pickup_time

  validates :pickup_type, presence: true
  validates :bag_price, presence: true
  validates :detergent, presence: true
  validates :softener, presence: true
  validates :region_id, presence: true
  validates :bag_count, presence: true, numericality: {other_than: 0}

  validates :ref_code, presence: true, unless: :skip_finalization_attributes
  validates :address, presence: true, unless: :skip_finalization_attributes
  validates :accept_by, presence: true, unless: :skip_finalization_attributes
  validates :subtotal, presence: true, unless: :skip_finalization_attributes
  validates :tax, presence: true, unless: :skip_finalization_attributes
  validates :tax_rate, presence: true, unless: :skip_finalization_attributes
  validates :grandtotal, presence: true, unless: :skip_finalization_attributes
  validates :washer_pay, presence: true, unless: :skip_finalization_attributes
  validates :profit, presence: true, unless: :skip_finalization_attributes
  validates :est_delivery, presence: true, unless: :skip_finalization_attributes
  validates :zipcode, presence: true, unless: :skip_finalization_attributes
  validates :full_address, presence: true, unless: :skip_finalization_attributes
  validates :address_lat, presence: true, unless: :skip_finalization_attributes
  validates :address_lng, presence: true, unless: :skip_finalization_attributes
  validates :tip, presence: true, unless: :skip_finalization_attributes
  validates :washer_final_pay, presence: true, unless: :skip_finalization_attributes
  validates :washer_ppb, presence: true, unless: :skip_finalization_attributes
  validates :washer_ppb, presence: true, unless: :skip_finalization_attributes
  validates :payout_desc, presence: true, unless: :skip_finalization_attributes
  validates :est_pickup_by, presence: true, unless: :skip_finalization_attributes
  validates :stripe_charge_id, presence: true, unless: :skip_charge_validate
  validates :delivery_photo_base64, length: { maximum: 15000 }
  
  # validates_numericality_of :customer_rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5, message: 'must be between 1 & 5'

  enum pickup_type: %i[
    asap
    scheduled
  ]

  enum status: %i[
    created
    washer_accepted
    enroute_for_pickup
    arrived_for_pickup
    picked_up
    completed
    delivered
    cancelled
  ]

  enum detergent: %i[
    dropps_clean_detergent
    dropps_sensitive_detergent
    use_own_detergent
  ]

  enum softener: %i[
    dropps_clean_softener
    dropps_unscented_softener
    use_own_softener
    no_softener
  ]

  enum delivery_location: %i[
    front_door
    back_door
    mail_room
    secure_location
    with_building_concierge
  ]

  ACCEPT_LIMIT = 45.minutes
  START_LIMIT = 45.minutes
  ABANDON_LIMIT = 45.minutes

  DETERGENTS = [
    {
    value: 'CLEAN',
    enum: 'dropps_clean_detergent',
    },
    {
      value: 'SENSITIVE',
      enum: 'dropps_sensitive_detergent',
    },
    {
      value: 'USE OWN',
      enum: 'use_own_detergent',
    }
  ]

  SOFTENERS = [
    {
      value: 'CLEAN',
      enum: 'dropps_clean_softener',
    },
    {
      value: 'UNSCENTED',
      enum: 'dropps_unscented_softener',
    },
    {
      value: 'USE OWN',
      enum: 'use_own_softener',
    },
    {
      value: 'NONE',
      enum: 'no_softener',
    },
  ]

  TIP_OPTIONS = [0,3,5,7]
  READABLE_TIP_OPTIONS = ['$0','$3','$5','$7']

  def scheduled?
    pickup_type == 'scheduled'
  end

  def scheduled_pickup
    scheduled? ? est_pickup_by : nil
  end

  def readable_est_pickup_by
    est_pickup_by.today? ? "Today at #{est_pickup_by.strftime('%I:%M%P')}" : est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')
  end

  def current_todo
    case status
    when 'washer_accepted'
      scheduled? ? readable_scheduled : "Pick Up #{bag_count} Bags (By #{est_pickup_by.strftime('%I:%M%P')})"
    when 'enroute_for_pickup'
      scheduled? ? readable_scheduled : "Pick Up #{bag_count} Bags (By #{est_pickup_by.strftime('%I:%M%P')})"
    when 'arrived_for_pickup'
      scheduled? ? readable_scheduled : "Pick Up #{bag_count} Bags (By #{est_pickup_by.strftime('%I:%M%P')})"
    when 'picked_up'
      "Wash & Deliver #{bag_count} Bags By #{readable_return_by}"
    when 'completed'
      "Deliver #{bag_count} Bags By #{readable_return_by}"
    when 'delivered'
      "Completed"
    when 'cancelled'
      "Cancelled"
    end
  end

  # enum delivery_location: %i[
  #   front_door
  #   back_door
  #   mail_room
  #   secure_location
  #   with_building_concierge
  # ]

  def readable_delivery_location
    case delivery_location
    when 'front_door'
      'At the front door.'
    when 'back_door'
      'At the back door.'
    when 'mail_room'
      'In a Secure Mailroom'
    when 'secure_location'
      'In a Secure Location'
    when 'with_building_concierge'
      'With Management or Concierge'
    else
      nil
    end
  end

  def readable_delivered
    delivered_at ? delivered_at.strftime('%m/%d/%Y at %I:%M%P') :nil
  end

  def tip_included?
    tip > 0
  end

  def readable_detergent
    case detergent
    when 'dropps_clean_detergent'
      "DROPPS™ CLEAN SCENT"
    when 'dropps_sensitive_detergent'
      "DROPPS™ SENSITIVE SKIN"
    when 'use_own_detergent'
      "CUSTOMER INCLUDED DETERGENT"
    end
  end

  def short_detergent
    case detergent
    when 'dropps_clean_detergent'
      "DROPPS™ CLEAN"
    when 'dropps_sensitive_detergent'
      "DROPPS™ SENSITIVE"
    when 'use_own_detergent'
      "USE OWN"
    end
  end

  def short_softener
    case softener
    when 'dropps_clean_softener'
      "DROPPS™ CLEAN"
    when 'dropps_unscented_softener'
      "DROPPS™ UNSCENTED"
    when 'use_own_softener'
      "USE OWN"
    when 'no_softener'
      "NONE"
    end
  end

  def readable_softener
    case softener
    when 'dropps_clean_softener'
      "DROPPS™ CLEAN SOFTENER"
    when 'dropps_unscented_softener'
      "DROPPS™ UNSCENTED SOFTENER"
    when 'use_own_softener'
      "CUSTOMER INCLUDED SOFTENER"
    when 'no_softener'
      "NO SOFTENER"
    end
  end

  def readable_washer_pay
    "$#{format('%.2f', washer_pay)} + Tips"
  end

  def miles_away(origin)
    if origin[:lat].present? && 
      origin[:lng].present? && 
      address_lat.present? && 
      address_lng.present?
      
     "#{Geocoder::Calculations.distance_between(
       [origin[:lat], origin[:lng]],
       [address_lat, address_lng]
     ).round(2)} mi"
   else
     "Unknown"
   end
  end

  def lat_lng
    [address_lat, address_lng].compact.join('/')
  end
  
  def readable_scheduled
    if scheduled?
      est_pickup_by.today? ? "Today #{est_pickup_by.strftime('at %I:%M%P')}" : "Scheduled Pick Up #{est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')}"
    else 
      nil
    end
  end
  
  def short_readable_scheduled
    if scheduled?
      est_pickup_by.today? ? "Today #{est_pickup_by.strftime('at %I:%M%P')}" : "#{est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')}"
    else 
      nil
    end
  end 

  def readable_est_delivery
    "#{est_delivery.strftime('%m/%d/%Y (by 9pm)')}".titleize
  end

  def readable_return_by
    "#{est_delivery.strftime('%m/%d/%Y (by %I:%M%P)')}".titleize
  end

  # STATUS UPDATES START
  def readable_status
    case status
    when 'created'
      scheduled ? readable_scheduled : "Pending Pickup"
    when "washer_accepted"
      scheduled ? readable_scheduled : "Pending Pickup"
    when "enroute_for_pickup"
      scheduled ? readable_scheduled : "Pending Pickup"
    when "arrived_for_pickup"
      scheduled ? readable_scheduled : "Pending Pickup"
    when 'picked_up'
      "Picked up on #{picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'completed'
      "Picked up on #{picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'delivered'
      "Delivered on #{delivered_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'cancelled'
      "Cancelled"
    end
  end

  def customer_status
    case status
    when 'created'
      scheduled? ? "Scheduled for #{est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')}" : "Waiting for Courier"
    when 'washer_accepted'
     scheduled? ? "Scheduled for #{est_pickup_by.strftime('%m/%d/%Y at %I:%M%P')}" : "Accepted by #{washer.abbrev_name}"
    when 'enroute_for_pickup'
      "#{washer.abbrev_name} is on their way"
    when 'arrived_for_pickup'
      "#{washer.abbrev_name} has arrived for pickup"
    when 'picked_up'
      "Your laundry was picked up on #{picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'completed'
      "Your laundry was picked up on #{picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'delivered'
      "Your laundry was delivered on #{delivered_at.strftime('%m/%d/%Y at %I:%M%P')}"
    when 'cancelled'
      "Order Cancelled"
    end
  end
  
  def washer_trackable?
    washer && 
    status != 'washer_accepted' &&
    status != 'picked_up' &&
    status != 'completed' &&
    status != 'delivered' && 
    status != 'cancelled'
  end

  def not_cancelled?
    status != 'cancelled'
  end

  def offer_not_expired?
    washer || DateTime.current < accept_by
  end

  def expired?
    !washer && accept_by < DateTime.current
  end

  def expires_soon?
    !washer && 
    accept_by > DateTime.current && 
    accept_by < 10.minutes.from_now
  end

  def wait_for_washer_refreshable?
    !washer && DateTime.current > accept_by && status != 'cancelled'
  end

  def refresh_wait_for_washer
    @extended_time = DateTime.current + ACCEPT_LIMIT
    update(
      accept_by: @extended_time,
      created_at: DateTime.current,
      est_pickup_by: @extended_time
    )
  end 

  def self.gen_pickup_estimate
    @minutes = rand(55..65)
    DateTime.current + @minutes.minutes
  end

  def drop_washer 
    update(
      accept_by: DateTime.current + 45.minutes,
      created_at: DateTime.current,
      washer_id: nil,
      status: 'created',
      enroute_for_pickup_at: nil,
      picked_up_at: nil,
      completed_at: nil,
      delivered_at: nil
    )
  end

  def take_washer(washer)
    update(
      washer_id: washer.id,
      status: 'washer_accepted'
    )
  end

  def soft_cancel
    update(
      status: 'cancelled', 
      cancelled_at: DateTime.current
    )
  end

  def cancellable?
    status != 'enroute_for_pickup' &&
    status != 'arrived_for_pickup' &&
    status != 'picked_up' &&
    status != 'completed' &&
    status != 'delivered' &&
    status != 'cancelled' &&
    !picked_up_at &&
    !completed_at &&
    !delivered_at
  end

  def cancel!
    @refund = Stripe::Refund.create(
      charge: stripe_charge_id
    )

    update(
      cancelled_at: DateTime.current, 
      status: 'cancelled',
      stripe_refund_id: @refund.id
    )
  end

  def mark_enroute_for_pickup
    update(
      enroute_for_pickup_at: DateTime.current, 
      status: 'enroute_for_pickup'
    )
  end

  def washer_within_arrival_range?(current_location_params)
    @distance = (((Geocoder::Calculations.distance_between(
      [current_location_params[:lat].to_f, current_location_params[:lng].to_f], 
      [self.address_lat, self.address_lng]
    )) * 100) / 100)

    @distance < 0.04
  end 

  def mark_arrived_for_pickup
    update(
      arrived_for_pickup_at: DateTime.current,
      status: 'arrived_for_pickup'
    )
  end

  def washer_adjust_bag_count(bag_count)
    update(
      bag_count: bag_count,
      washer_adjusted_bag_count_at: DateTime.current
    )
  end

  def mark_picked_up(code_array)
    update(
      bag_codes: code_array.split(',').join('/'),
      picked_up_at: DateTime.current,
      status: 'picked_up'
    )
  end

  def completable?
    # (picked_up_at + 90.minutes) < DateTime.current

    # allow instant completion (DEBUG)
    picked_up_at < DateTime.current
  end

  def min_completable_time
    (picked_up_at + 90.minutes).strftime('%m/%d/%Y at %I:%M%P')
  end

  def mark_completed
    update(
      completed_at: DateTime.current,
      status: 'completed'
    )
  end

  def mark_delivered
    update(
      delivered_at: DateTime.current,
      readable_delivered_at: DateTime.current.strftime('%m/%d/%Y'),
      status: 'delivered'
    )
  end

  def save_delivery_data(params)
    update(
      delivery_photo_base64: params[:delivery_photo_base64],
      delivery_location: params[:delivery_location]
    )
  end

  def mark_cancelled
    update(
      cancelled_at: DateTime.current,
      status: 'cancelled'
    )
  end
  # STATUS UPDATES END

  def not_taken?
    washer_id.blank?
  end

  def seconds_to_accept
     ((accept_by - DateTime.current)).to_i
  end

  def total_seconds
    (accept_by - created_at).to_i
  end

  def percent_left_to_accept
    ((seconds_to_accept.to_f / total_seconds.to_f) * 100).round
  end

  def self.calc_subtotal(bag_count, price_per_bag)
    bag_count * price_per_bag
  end

  def self.calc_tax(subtotal, tax_rate)
    (subtotal * tax_rate).round(2)
  end

  def self.calc_grandtotal(subtotal, tax, tip)
    # tip can be 0
    subtotal + tax + tip
  end

  def self.calc_washer_ppb(subtotal, washer_pay_percentage, bag_count)
    subtotal * washer_pay_percentage / bag_count
  end
 
  def self.calc_washer_pay(subtotal, washer_pay_percentage)
    # washer_pay_percentage comes from region
    (subtotal * washer_pay_percentage)
  end

  def self.calc_washer_final_pay(subtotal, washer_pay_percentage, tip)
    (subtotal * washer_pay_percentage) + tip
  end

  def self.calc_processing_fee(grandtotal)
    (grandtotal * 0.029 + 0.3)
  end

  def self.calc_profit(subtotal, washer_pay, pmt_processing_fee)
    subtotal - washer_pay - pmt_processing_fee
  end

  def charge_order!(current_user)
    @charge = Stripe::Charge.create(
      amount: (self.grandtotal * 100).to_i,
      currency: 'usd',
      description: "FRESHANDTUMBLE.COM Order# #{self.ref_code}",
      statement_descriptor: 'FRESH AND TUMBLE LLC',
      customer: current_user.stripe_customer_id
    )

    self.update(
      stripe_charge_id: @charge.id 
    )
  end

  def readable_decimal(attribute)
    "#{format('%.2f', attribute)}"
  end

  def self.readable_decimal(attribute)
    "#{format('%.2f', attribute)}"
  end

  def get_stripe_transaction
    Stripe::Charge.retrieve(stripe_charge_id)
  end

  def get_stripe_transfer
    Stripe::Transfer.retrieve(stripe_transfer_id)
  end

  def get_stripe_refund
    Stripe::Refund.retrieve(stripe_refund_id)
  end

  def partial_refund!(amount)
    @refund = Stripe::Refund.create({
      charge: stripe_charge_id,
      amount: amount
    })

    update(stripe_refund_id: @refund.id)
  end

  def custom_washer_payout(amount)
    # don't use source transaction because if a weird adjustment is made to an order withi lots of missing bags, the transfer will exceed the source transaction amount (profit $-0.76 or whatever)
    if washer.payoutable_as_ic
      @transfer = Stripe::Transfer.create({
        amount: amount.to_i,
        # source_transaction: stripe_charge_id,
        currency: 'usd',
        description: "FRESHANDTUMBLE.COM PAYOUT: #{ref_code}",
        destination: washer.stripe_account_id
      })

      update(stripe_transfer_id: @transfer.id)
    end
  end

  def payout_washer!
    if washer.payoutable_as_ic
      @transfer = Stripe::Transfer.create({
        amount: (washer_final_pay * 100).to_i,
        # source_transaction: stripe_charge_id,
        currency: 'usd',
        description:  "FRESHANDTUMBLE.COM PAYOUT: #{payout_desc}",
        destination: washer.stripe_account_id
      }) 

      update(
        stripe_transfer_id: @transfer.id
      )
    end
  end

  def self.new_payout_desc(tip, washer_final_pay)
    if tip > 0
      @payout_desc = "$#{NewOrder.readable_decimal(washer_final_pay)} (includes $#{NewOrder.readable_decimal(tip)} tip)"
    else
      @payout_desc = "$#{NewOrder.readable_decimal(washer_final_pay)}"
    end
  end

  # EMAILS
  def send_new_order_email!(region, user, address)
    Users::NewOrderMailer.send_email(region, user, address, self).deliver_later
  end

  def send_delivered_email!(user)
    Users::DeliveredMailer.send_email(self, user).deliver_later
  end

  def send_cancelled_order_email!(user)
    Users::CancelledNewOrderMailer.send_email(user, self).deliver_later
  end

  def send_missing_bags_email!(user, old_bag_count, missing_bags_count)
    Users::MissingBagsMailer.send_email(self, user, old_bag_count, missing_bags_count).deliver_later
  end

  def send_failed_pickup_email!(user, offer_event, fee)
    Users::FailedPickupMailer.send_email(self, offer_event, user, fee).deliver_later
  end

  def alert_washers_in_region!
    @washers = region.washers.activated

    if @washers.any?
      @washers.each do |w|
        SmsAlertUntrackedWorker.perform_async(
          w.phone, "There are new Wash Offers Available in The Fresh And Tumble Washer App. Grab one before they're gone!"
        )
      end
    end
  end

  # REVENUE METRICS START
  def self.revenue_today
    NewOrder
      .today
      .delivered
      .sum(:grandtotal)
      .round(2)
  end
  
  def self.revenue_mtd
    NewOrder
      .mtd
      .delivered
      .sum(:grandtotal)
      .round(2)
  end
  
  def self.revenue_ytd
    NewOrder
      .ytd
      .delivered
      .sum(:grandtotal)
      .round(2)
  end

  def self.tax_collected_today
    NewOrder
      .today
      .delivered
      .sum(:tax)
      .round(2)
  end

  def self.tax_collected_mtd
    NewOrder
      .mtd
      .delivered
      .sum(:tax)
      .round(2)
  end

  def self.tax_collected_ytd
    NewOrder
      .ytd
      .delivered
      .sum(:tax)
      .round(2)
  end

  def self.average_purchase_value
    # total revenue / number of transactions/orders
    if NewOrder.any?
      (NewOrder
      .delivered
      .sum(:grandtotal)
      .round / NewOrder.count).round(2)
    else
      0
    end
  end

  def self.average_order_frequency_per_month
    @frequency_collection = []
    @customers = User.joins(:new_orders)
    .group('users.id')
    .having('count(new_orders) > 1')

    if @customers.any?
      @customers.each do |customer|
        orders = customer.new_orders

        span_secs = orders.maximum(:created_at) - orders.minimum(:created_at)
        avg_secs = span_secs / (orders.count - 1)
        avg_days = avg_secs / (24 * 60 * 60)
        avg_in_month = avg_days / 30

        @frequency_collection.push(avg_in_month)
      end

      (@frequency_collection.sum / @customers.length).round(2)
    else
      0
    end
  end
  # REVENUE METRICS END

  # DEBUG
  # requires User.first to have a region and address
  # all offers are startable, even if scheduled.
  def self.sample_offers!(count)
    @user = User.first
    @address = @user.address
    @region = @user.address.region

    @customer = Stripe::Customer.create(
      source: 'tok_visa',
      email: @user.email
    )
  
    @card = @customer.sources.data.first
  
    @user.update_attributes(
      stripe_customer_id: @customer.id,
      card_brand: @card[:brand],
      card_exp_month: @card[:exp_month],
      card_exp_year: @card[:exp_year],
      card_last4: @card[:last4]
    )
    @user.reload

    count.times do 
      @bag_count = rand(2..4)
      # @bag_count = 1
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
        @payout_desc = "$#{NewOrder.readable_decimal(@washer_final_pay)} (includes $#{NewOrder.readable_decimal(@tip)} tip)"
      else
        @payout_desc = "$#{NewOrder.readable_decimal(@washer_final_pay)}"
      end

      p '****NEW ORDER********'
      p "bag price: $#{@price_per_bag}"
      p "subtotal: $#{format('%.2f', @subtotal)}"
      p "tax: $#{format('%.2f', @tax)}"
      p "grandtotal: $#{format('%.2f', @grandtotal)}"
      p "bags: #{@bag_count}"
      p "tip: $#{format('%.2f', @tip)}"
      p "washer ppb $#{format('%.2f', @washer_ppb)}"
      p "washer pay: $#{format('%.2f', @washer_pay)}"
      p "washer final pay: $#{format('%.2f', @washer_final_pay)}"
      p "washer percentage #{(@region.washer_pay_percentage * 100).to_i}%"
      p "profit: $#{format("%.2f", @profit)}"
      
      @new_order = @user.new_orders.create!(
        pickup_type: 'scheduled',
        ref_code: SecureRandom.hex(5),
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        est_pickup_by: DateTime.current + (NewOrder::START_LIMIT - 1.minutes),
        bag_count: @bag_count, 
        est_delivery: DateTime.current + 24.hours,
        accept_by: DateTime.current + ACCEPT_LIMIT,
        wash_notes: Faker::Quote.matz,
        directions: 'Side door behind the garage.',
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
        stripe_charge_id: 'asdfasdf',
        full_address: @address.full_address,
        address_lat: @address.latitude,
        address_lng: @address.longitude
      )

      @charge = Stripe::Charge.create(
        amount: (@new_order.grandtotal * 100).to_i,
        currency: 'usd',
        description: "FRESHANDTUMBLE.COM Order # #{@new_order.ref_code}",
        statement_descriptor: 'FRESH AND TUMBLE LLC',
        customer: @user.stripe_customer_id
      )
      @new_order.update(stripe_charge_id: @charge.id )
      
      p @new_order.readable_est_pickup_by
    end
  end

  def get_took
    update(washer_id: 5)
  end

  def reopen_offer
    update(
      accept_by: DateTime.current + ACCEPT_LIMIT,
      created_at: DateTime.current,
      est_pickup_by: DateTime.current + ACCEPT_LIMIT,
      washer_id: nil,
      status: 'created',
      enroute_for_pickup_at: nil,
      picked_up_at: nil,
      completed_at: nil,
      delivered_at: nil
    )
  end 

  def expire!
    update_attributes!(accept_by: DateTime.current - 1.minutes)
  end

  def expire_in_10
    update_attributes!(accept_by: DateTime.current + 10.seconds)
  end

  def temp_cancel
    @status = self.status
    update(status: 'cancelled')
    sleep 10.seconds
    update(status: @status)
  end

  def temp_swap_pickup_type
    @pickup_type = pickup_type

    if @pickup_type == 'scheduled'
      update(pickup_type: 'asap')
    else
      update(pickup_type: 'scheduled')
    end
    sleep 10.seconds

    update(pickup_type: @pickup_type)
  end

  def temp_allow_sms
    @phone = self.user.phone
    self.user.update(phone: '5627872684')
    sleep 30.seconds
    self.user.update(phone: @phone)
  end

  def temp_make_startable
    @est_pickup_by = self.est_pickup_by + 30.seconds
    update(est_pickup_by: DateTime.current + 1.minutes)
    sleep 30.seconds
    update(est_pickup_by: @est_pickup_by)
  end

  def simulate_pickup
    p 'SIMULATING PICKUP START'
    @order = self
    p 'RESETTING PICKUP'
    @order.reopen_offer
    p 'PICKUP RESET'
    p 'PICKUP WILL BEGIN IN 15 SECONDS'
    sleep 15.seconds
    @washer = Washer.first
    p "WASHER #{@washer.abbrev_name} is accepting offer"
    @order.take_washer(@washer)
    p "WASHER #{@washer.abbrev_name} has accepted offer"
    p 'WAITING 15 SECONDS FOR WASHER TO START PICKUP'
    sleep 15.seconds
    @order.mark_enroute_for_pickup
    @washer.update(
      current_lat: 47.6197,
      current_lng: -122.3489
    )
    p "WASHER IS NOW ENROUTE TO CUSTOMER FOR PICKUP FROM THE SPACE NEEDLE"
    sleep 15.seconds
    @washer.update(
      current_lat: 47.4981,
      current_lng: -122.3089
    )
    p "WASHER IS NOW AT 711"
    sleep 15.seconds
    @washer.update(
      current_lat: 47.4986,
      current_lng: -122.3165
    )
    @order.mark_arrived_for_pickup
    p "WASHER IS NOW AT 1233 S 117TH ST AND HAS ARRIVED"
    sleep 15.seconds
    p "WAITING 15 SECONDS FOR WASHER TO PICKUP ORDER"
    sleep 15.seconds
    @codes_params = []
    @order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @order.mark_picked_up(JSON.parse(@codes_params.to_json))
    p 'WASHER HAS NOW PICKED UP ORDER AND PICKUP IS COMPLETE YAY!!'
    p "RESETTING OFFER IN 15 SECONDS"
    sleep 15.seconds
    @order.reopen_offer
    p "OFFER HAS BEEN RESET"
  end

end
