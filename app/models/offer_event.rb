# == Schema Information
#
# Table name: offer_events
#
#  id           :bigint           not null, primary key
#  washer_id    :bigint
#  new_order_id :bigint
#  event_type   :integer
#  feedback     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class OfferEvent < ApplicationRecord
  scope :user_seeable, -> { where(event_type: %w[
    offer_accepted
    offer_picked_up
    cannot_locate_order_address_access_pickup
    cannot_locate_order_business_closed_pickup
    customer_cancelled_pickup
  ])}
  belongs_to :washer
  belongs_to :new_order

  validates :event_type, presence: true

  enum event_type: %i[
    offer_accepted
    offer_hidden
    offer_abandoned
    started_offer
    enroute_for_pickup
    enroute_for_delivery
    arrived_for_pickup
    scanned_customer_bags_pickup
    scanned_customer_bags_delivery
    completed_pickup
    arrived_for_delivery
    order_processed
    gps_arrived_problem_pickup
    gps_arrived_problem_delivery
    cannot_scan_bag_codes_pickup
    cannot_scan_bag_codes_delivery
    bags_missing_pickup
    all_bags_missing_pickup
    bags_overstuffed_pickup
    cannot_locate_order_address_access_pickup
    cannot_locate_order_address_access_delivery 
    cannot_locate_order_business_closed_pickup
    cannot_locate_order_business_closed_delivery
    customer_cancelled_pickup
    cannot_wash
    delivered
  ]

  def readable_event_type
    case event_type
    when 'offer_accepted'
      'ACCEPTED OFFER'
    when 'offer_hidden'
      'HID OFFER'
    when 'offer_abandoned'
      'ABANDONED OFFER'
    when 'started_offer'
      'STARTED OFFER'
    when 'enroute_for_pickup'
      'BEGAN TRAVEL FOR PICKUP'
    when 'enroute_for_delivery'
      'BEGAN TRAVEL FOR DELIVERY'
    when 'arrived_for_pickup'
      'ARRIVED FOR PICKUP'
    when 'scanned_customer_bags_pickup'
      'SCANNED CUSTOMER BAGS FOR PICKUP'
    when 'scanned_customer_bags_delivery'
      'SCANNED CUSTOMER BAGS FOR DELIVERY'
    when 'completed_pickup'
        'COMPLETED PICKUP'
    when 'arrived_for_delivery'
        'ARRIVED FOR DELIVERY'
    when 'order_processed'
       'FINISHED WASHING'
    when 'gps_arrived_problem_pickup'
      "USED RESCUE TO ARRIVE FOR PICKUP"
    when 'gps_arrived_problem_delivery'
      "USED RESCUE TO ARRIVE FOR DELIVERY"
    when 'cannot_scan_bag_codes_pickup'
      "USED RESCUE TO MANUALLY ENTER BAG CODES FOR PICKUP"
    when 'cannot_scan_bag_codes_delivery'
      "COULDN'T SCAN BAGS FOR DELIVERY"
    when 'bags_missing_pickup'
      "USED RESCUE TO ADJUST BAG COUNT (MISSING BAGS)"
    when 'all_bags_missing_pickup'
      "RESCUE FAILED PICKUP (ALL BAGS MISSING)"
    when 'bags_overstuffed_pickup'
      "PICKUP FAILED REFUSED: (BAGS OVERSTUFFED)"
    when 'cannot_locate_order_address_access_pickup'
      "CANNOT ACCESS ADDRESS FOR PICKUP"
    when 'cannot_locate_order_address_access_delivery'
      "CANNOT ACCESS ADDRESS FOR DELIVERY"
    when 'cannot_locate_order_business_closed_pickup'
      "BUSINESS CLOSED FOR PICKUP"
    when 'cannot_locate_order_business_closed_delivery'
      "BUSINESS CLOSED FOR DELIVERY"
    when 'customer_cancelled_pickup'
      "INDICATED CUSTOMER CANCELLED PICKUP"
    when 'cannot_wash'
      "CANNOT WASH ONE OR MORE ITEMS"
    when 'delivered'
      "DELIVERED ORDER"
    else
      "Unknown"
    end
  end

  REMINDER_INTRO = 'On your next Order, please ensure that'
  def customer_reminder
    case event_type
    when 'cannot_locate_order_address_access_pickup'
      "#{REMINDER_INTRO} your Order is accessible for our Washer to pick up."
    when 'cannot_locate_order_business_closed_pickup'
      "#{REMINDER_INTRO} your business is open or that your Order accessible for our Washer to pick up."
    when 'customer_cancelled_pickup'
      "#{REMINDER_INTRO} your laundry is accessible and available for your Washer to pick up."
    when 'all_bags_missing_pickup'
      "#{REMINDER_INTRO} your bags are available for our Washer to pick up."
    end
  end

  # debug
  def self.cleanup_deleted_orders
    OfferEvent.all.each do |o|
      if !o.new_order
        o.destroy
      end
    end
  end

end
