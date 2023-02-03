# frozen_string_literal: true

# == Schema Information
#
# Table name: orders
#
#  id                                      :bigint           not null, primary key
#  user_id                                 :bigint
#  order_total                             :decimal(12, 2)
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  reference_code                          :string
#  pick_up_time                            :string
#  worker_id                               :integer
#  full_address                            :string
#  customer_lat                            :float
#  customer_long                           :float
#  pick_up_date                            :datetime
#  bags_code                               :string
#  bags_collected                          :integer
#  picked_up_from_customer_at              :datetime
#  dropped_off_to_partner_at               :datetime
#  picked_up_from_partner_at               :datetime
#  delivered_to_customer_at                :datetime
#  courier_weight                          :float
#  partner_reported_weight                 :float
#  global_status                           :integer          default("created")
#  pick_up_from_customer_status            :integer          default("pick_up_from_customer_not_started")
#  drop_off_to_partner_status              :integer          default("drop_off_to_partner_not_started")
#  partner_location_id                     :integer
#  marked_as_ready_for_pickup_from_partner :boolean          default(FALSE)
#  pick_up_from_partner_status             :integer          default("pick_up_from_partner_not_started")
#  deliver_to_customer_status              :integer          default("delivery_to_customer_not_started")
#  courier_stated_delivered_location       :string
#  delivery_attempts                       :integer          default(0)
#  checkout_holding_order_status           :integer
#  routable_address                        :string
#  detergent                               :integer
#  softener                                :integer
#  region_pricing_id                       :integer
#  client_id                               :bigint
#  unwashable_items                        :boolean          default(FALSE)
#  pick_up_directions                      :string
#

class Order < ApplicationRecord
  scope :redeliveries, -> { where(global_status: 'delayed_reattempt_delivery')}
  scope :not_started, -> { where(global_status: 'created')}
  scope :picked_up, -> { where(global_status: 'picked_up')}
  scope :processing, -> { where(global_status: 'processing') }
  scope :deliverable, -> { where(global_status: %w[ready_for_delivery out_for_delivery delayed])}
  scope :delivered, -> { where(global_status: 'delivered')}
  scope :cancelled, -> { where(global_status: %w[cancelled cancelled_unable_to_pickup])}
  scope :problem, -> { where(global_status: %w[cancelled
  cancelled_unable_to_pickup in_holding_unable_to_deliver])}
  scope :reattemptable, -> { where(global_status: 'delayed_reattempt_delivery')}
  scope :delayed, -> { where(global_status: %w[delayed delayed_reattempt_delivery])}
  scope :in_holding, -> { where(global_status: 'in_holding_unable_to_deliver') }
  scope :in_progress, -> { where.not(global_status: %w[cancelled delivered cancelled_unable_to_pickup])}
  
  belongs_to :user, optional: true
  belongs_to :partner_location, optional: true
  belongs_to :client, optional: true
  belongs_to :worker, optional: true
  belongs_to :washer, optional: true
  belongs_to :region_pricing, optional: true
  has_one :appointment
  has_many :transactions
  has_many :notifications
  has_many :courier_problems
  has_many :support_tickets
  validates :full_address, presence: true
  validates :routable_address, presence: true
  validates :pick_up_date, presence: true
  validates :pick_up_time, presence: true
  validates :detergent, presence: true
  validates :softener, presence: true

  enum global_status: %i[
    created
    picked_up
    processing
    ready_for_delivery
    out_for_delivery
    delivered
    delayed
    delayed_reattempt_delivery
    cancelled
    cancelled_unable_to_pickup
    in_holding_unable_to_deliver
    checked_out_holding_order
  ]

  enum detergent: %i[
    tide_original
    tide_hypoallergenic
    regular_detergent
    hypoallergenic
    use_own_soap
  ]

  enum softener: %i[
    bounce
    snuggle
    hypo_allergenic
    no_softener
    regular_softener
    use_own_softener
  ]

  enum pick_up_from_customer_status: %i[
    pick_up_from_customer_not_started
    pick_up_from_customer_started
    arrived_at_customer_for_pickup
    acknowledged_customer_pickup_directions
    collected_customer_bags
    rejected
    picked_up_from_customer
  ]
  # picked_up_from_customer sets global status to :picked_up

  enum drop_off_to_partner_status: %i[
    drop_off_to_partner_not_started
    arrived_at_partner_for_dropoff
    scanned_existing_bags_for_order
    recorded_partner_weight
    acknowledged_drop_off_directions
    dropped_off_to_partner
  ]
  # dropped_off_to_partner sets global status to :processing

  enum pick_up_from_partner_status: %i[
    pick_up_from_partner_not_started
    arrived_at_partner_for_pickup
    acknowledged_partner_pickup_directions
    scanned_existing_bags_for_pickup_from_partner
    picked_up_from_partner
  ]
  # picked_up_from_partner sets global status to :ready_for_delivery

  enum deliver_to_customer_status: %i[
    delivery_to_customer_not_started
    arrived_at_customer_for_delivery
    scanned_existing_bags_for_delivery
    delivered_to_customer
  ]
  # delivered_to_customer sets global status to :delivered

  enum checkout_holding_order_status: %i[
    acknowledged_scan_directions
    checked_out
  ]
  # checked_out sets global status to "checked_out_holding_order"

  def formatted_pickup_time
    case pick_up_time
    when 'morning'
      '(7AM-10AM)'
    when 'afternoon'
      '(3PM-5PM)'
    when 'evening'
      '(6PM-8PM)'
    else
      pick_up_time
    end
  end

  def formatted_appointment
		if pick_up_date.today?
			"Today at #{formatted_pickup_time}"
		else
			"#{pick_up_date.strftime('%m/%d/%Y')} at #{formatted_pickup_time}"
		end
	end
		
  def estimated_delivery
    if pick_up_date.today?
      "Tomorrow (#{(pick_up_date.tomorrow).strftime('%m/%d/%Y')}) by 9pm"
    else
      "#{(pick_up_date.tomorrow).strftime('%m/%d/%Y')} by 9pm"
    end
	end

  def condensed_appointment
    "#{pick_up_date.strftime('%m/%d/%Y')} at #{pick_up_time}"
	end
	
	def google_nav_link
    formatted_link = []

    routable_address.split(',').each do |r|
      formatted_link.push(r.split(' ').join('+'))
    end
    # second slash is required to have the address be the destination instead of the origin
    @link = "https://www.google.com/maps/dir//#{formatted_link.join(',')}"
  end

  def readable_picked_up_at
    picked_up_from_customer_at.strftime('%m/%d/%Y at %I:%M%P')
  end

  def readable_dropped_off_to_partner_at
    dropped_off_to_partner_at.strftime('%m/%d/%Y at %I:%M%P')
  end

  def readable_delivered
    delivered_to_customer_at.strftime('%m/%d/%Y at %I:%M%P')
  end

  def completed?
    global_status == 'delivered' || global_status == 'delayed_reattempt_delivery' || global_status == 'in_holding_unable_to_deliver'
  end

  def cancellable_by_customer?
    global_status == 'created' && pick_up_from_customer_status == 'pick_up_from_customer_not_started'
  end

  def cancel!
    update_attribute(:global_status, 'cancelled')
    self.appointment.destroy!
  end

  def cancelled?
    global_status == 'cancelled' || global_status == 'cancelled_unable_to_pickup'
  end

  def not_cancelled?
    global_status != 'cancelled' && global_status != 'cancelled_unable_to_pickup'
  end

  def readable_created_at
    created_at.strftime('%m/%d/%Y')
  end

  def support_selectable
    "Order: #{self.reference_code} - Placed on #{self.readable_created_at}"
  end

  def readable_detergent
    case detergent
    when 'tide_original'
      "Tide Original".upcase
    when 'tide_hypoallergenic'
      "Tide Hypoallergenic".upcase
    when 'regular_detergent'
      "Fresh Scent".upcase
    when 'hypoallergenic'
      "Gentle".upcase
    else
      "Unknown".upcase
    end
  end

  def readable_softener
    case softener
    when 'bounce'
      "Bounce".upcase
    when 'snuggle'
      "Snuggle".upcase
    when 'hypo_allergenic'
      "Gentle".upcase
    when 'no_softener'
      "No Softener".upcase
    when 'regular_softener'
      "Fresh Scent".upcase
    else
      "Unknown".upcase
    end
  end

  # charge calculation START

  def readable_courier_weight
    "#{format('%.2f', courier_weight)}lbs"
  end

  def readable_partner_weight
    "#{format('%.2f', partner_reported_weight)}lbs"
  end

  def minimum_weight_fee
    region_pricing.minimum_weight_fee
  end

  def readable_minimum_weight_fee
    "$#{format('%.2f', minimum_weight_fee)}"
  end

  def readable_weight
    self.transactions.first.readable_weight
  end

  def readable_grandtotal
    self.transactions.first.readable_grandtotal
	end

  def price_per_pound
    self.region_pricing.price_per_pound
  end

  def readable_price_per_pound
    "#{format('%.2f',  region_pricing.price_per_pound)} /lb"
   end

  def readable_grandtotal
    self.transactions.first.readable_grandtotal
	end
	
	def wash_hours_saved
		((courier_weight / 8) * 2).round(2)
	end

  def delivery_status
    case global_status
    when 'created'
      "Est. Delivery: #{estimated_delivery}"
    when 'picked_up'
      "Arrives #{estimated_delivery}"
    when 'processing'
      "Arrives #{estimated_delivery}"
    when 'ready_for_delivery'
      "Arrives #{estimated_delivery}"
    when 'delivered'
      "Delivered On: #{readable_delivered}"
    when 'delayed'
      "Delayed (Arrives Next Business Day)"
    when 'delayed_reattempt_delivery'
      "Courier Unable To Deliver (Reattempting)"
    when 'in_holding_unable_to_deliver'
      "Cannot Deliver: Contact Support"
    when 'checked_out_holding_order'
      "Completed"
    when 'cancelled'
      "Cancelled"
    when 'cancelled_unable_to_pickup'
      "Cancelled: Courier Could Not Pick Up"
    else
      "Unknown"
    end
  end

  def readable_delivered_location
    case courier_stated_delivered_location
    when 'front_door'
      "Front Door"
    when 'back_door'
      "Back Door"
    when 'customer_or_household_member'
      "With the customer or a household member"
    when 'secure_mailroom'
      "In a secure mailroom"
    else
      "In a secure location"
    end
  end

  def self.new_reference_code
    "LB-#{SecureRandom.hex(5)}".upcase
  end

  def lock_appointment!
    self.create_appointment!(
      pick_up_date: pick_up_date,
      pick_up_time: pick_up_time
    )
  end

  def notify_worker!
    Notification.send_sms!(
      @event = 'new_order',
      @user_type = 'worker',
      @id = Worker.first.id,
      @body = "📦 #{formatted_appointment}"
    )
  end

  def notify_worker_cancelled!
    Notification.send_sms!(
      @event = 'order_cancelled',
      @user_type = 'worker',
      @id = Worker.first.id,
      @body = "*CANCELLED*: #{formatted_appointment}"
    )
  end
      

  DELIVERY_ATTEMPT_LIMIT = 3
  def delivery_limit_reached?
    delivery_attempts >= DELIVERY_ATTEMPT_LIMIT
  end

  def remaining_delivery_attempts
    3 - delivery_attempts
	end

  def from_new_customer?
    self.user.orders.where(global_status: 'delivered').none?
  end

  # pickup from customer start
  def within_pickup_window?
    pick_up_date.today? && Time.parse(pick_up_time) < 1.hour.from_now
  end

  def startable?
    global_status != 'cancelled'
  end

  def mark_pick_up_started
    update_attribute(:pick_up_from_customer_status, 'pick_up_from_customer_started')
  end

  def mark_arrived_for_pickup
    self.update_attribute(:pick_up_from_customer_status, 'arrived_at_customer_for_pickup')
	end

  def mark_acknowledged_pickup_directions
    self.update_attribute(:pick_up_from_customer_status, 'acknowledged_customer_pickup_directions')
  end
  
  def mark_picked_up!
		update_attributes(
			global_status: 'picked_up',
			pick_up_from_customer_status: 'picked_up_from_customer',
			picked_up_from_customer_at: DateTime.current
		)
  end

  def self.active_labels
    Order.in_progress.pluck(:bags_code).compact
  end

	def pickup_labels_printed?
		bags_collected.present? && bags_code.present?
  end
  
  def self.generate_unique_label_code
    @active_labels = []
    Order.
    unique_codes = []
    50.times do
      code = "#{SecureRandom.hex(2)}".upcase
      @active_labels.push(code)
      unique_codes.push(code)
      unique_codes.uniq!
    end

    if @active_labels.length == unique_codes.length
      # puts '*************'
      # puts "it was unique!!"
      # puts "all codes #{all_codes}"
      # puts "unique codes #{unique_codes}"
      # puts '*************''
      # puts "yes"
    else
      puts '*************'
      puts "duplicates detected"
      # puts "all codes #{all_codes}"
      # puts "unique codes #{unique_codes}"
      puts '*************'
    end
  end

	def save_new_label(code, bag_count)
		update_attributes(
			bags_collected: bag_count,
			bags_code: code
		)
	end

	def valid_code?(code)
		bags_code == code
  end
  
  def save_courier_weight(weight)
    self.update_attributes!(courier_weight: weight)
  end

  def reject_pickup!
    update_attributes(
      global_status: 'cancelled',
      pick_up_from_customer_status: 'rejected'
    )
    self.appointment.destroy!
	end

	def mark_collected_customer_bags
		update_attribute(:pick_up_from_customer_status, 'collected_customer_bags')
	end

  def mark_unable_to_pick_up!
    update_attribute(:global_status, 'cancelled_unable_to_pickup')
  end

  def picked_up?
    picked_up_from_customer_at.present?
  end
  # pickup from customer end

  # dropoff to partner start

  def required_soap_portions
    (courier_weight / 12).ceil
  end

  def required_detergent
    (courier_weight / 12).ceil
  end

  def mark_arrived_at_partner_for_dropoff
    self.update_attribute(
      :drop_off_to_partner_status, 'arrived_at_partner_for_dropoff'
    )
  end

  def mark_scanned_for_partner_dropoff
    self.update_attribute(
      :drop_off_to_partner_status, 'scanned_existing_bags_for_order'
    )
  end

  def mark_recorded_partner_weight(weight)
    update_attributes(
      partner_reported_weight: weight,
      drop_off_to_partner_status: 'recorded_partner_weight'
    )
  end

  def mark_received_by_partner
    self.update_attributes(
      global_status: 'processing',
      drop_off_to_partner_status: 'dropped_off_to_partner',
      dropped_off_to_partner_at: DateTime.current
    )
  end
  # dropoff to partner end

  # pickup from partner start
  def mark_arrived_at_partner_for_pickup
    self.update_attribute(
      :pick_up_from_partner_status, 'arrived_at_partner_for_pickup'
    )
  end

  def mark_acknowledged_partner_pickup_directions
    self.update_attribute(
      :pick_up_from_partner_status, 'acknowledged_partner_pickup_directions'
    )
  end

  def mark_scanned_existing_bags_for_partner_pickup
    update_attribute(
      :pick_up_from_partner_status, 'scanned_existing_bags_for_pickup_from_partner'
    )
  end

	def mark_picked_up_from_partner
		update_attributes(
      global_status: 'ready_for_delivery',
      pick_up_from_partner_status: 'picked_up_from_partner',
      picked_up_from_partner_at: DateTime.current
    )
  end 
  # pickup from partner end

  # deliver to customer start

  def mark_arrived_at_customer_for_delivery
    self.update_attribute(
      :deliver_to_customer_status, 'arrived_at_customer_for_delivery'
    )
  end

  def mark_scanned_existing_bags_for_delivery
    self.update_attribute(
      :deliver_to_customer_status, 'scanned_existing_bags_for_delivery'
    )
  end
	# deliver to customer end
	
	def not_billed_yet?
		self.transactions.count == 0
  end
  
  def billed?
    self.transactions.count == 1
  end

  # checkout holding order start
  def mark_acknowledged_directions_for_manual_checkout
    self.update_attribute(
      :checkout_holding_order_status, 'acknowledged_scan_directions'
    )
  end

  def mark_picked_up_by_customer
    self.update_attributes(
      checkout_holding_order_status: 'checked_out',
      global_status: 'checked_out_holding_order'
    )
  end
  # checkout holding order end

  # courier problems rescue start

  def delay_delivery
    update_attributes(
      global_status: 'delayed',
      deliver_to_customer_status: 'delivery_to_customer_not_started'
    )
  end

  def mark_for_reattempt
    self.update_attributes(
      global_status: 'delayed_reattempt_delivery',
      deliver_to_customer_status: 'delivery_to_customer_not_started'
    )
  end

  def mark_as_undeliverable
    self.update_attribute(
      :global_status, 'in_holding_unable_to_deliver'
    )
  end
  # courier problems rescue end

  # DEBUG ONLY
  def reset_courier_state!
    update_attributes(
      global_status: 'created',
      pick_up_from_customer_status: 'pick_up_from_customer_not_started',
      drop_off_to_partner_status: 'drop_off_to_partner_not_started',
      pick_up_from_partner_status: 'pick_up_from_partner_not_started',
      deliver_to_customer_status: 'delivery_to_customer_not_started'
    )
  end
end
