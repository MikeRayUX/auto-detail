# == Schema Information
#
# Table name: commercial_pickups
#
#  id                                :bigint           not null, primary key
#  transaction_id                    :bigint
#  client_id                         :bigint
#  full_address                      :string
#  routable_address                  :string
#  reference_code                    :string
#  pick_up_directions                :string
#  bags_code                         :string
#  pick_up_window                    :integer
#  detergent                         :integer
#  softener                          :integer
#  global_status                     :integer          default("created")
#  bags_collected                    :integer
#  pick_up_date                      :datetime
#  picked_up_from_client_at          :datetime
#  dropped_off_to_partner_at         :datetime
#  picked_up_from_partner_at         :datetime
#  delivered_to_client_at            :datetime
#  weight                            :decimal(12, 2)
#  paid                              :boolean          default(FALSE)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  partner_location_id               :bigint
#  problem_encountered               :integer
#  courier_stated_delivered_location :integer
#  address_id                        :bigint
#  subtotal                          :decimal(12, 2)
#  tax                               :decimal(12, 2)
#  grandtotal                        :decimal(12, 2)
#  tax_rate                          :decimal(12, 2)
#  client_price_per_pound            :decimal(12, 2)
#

class CommercialPickup < ApplicationRecord
  scope :unpaid, -> { where(paid: false)}
  scope :paid, -> { where(paid: true)}
  scope :not_started, -> { where(global_status: 'created')}
  scope :picked_up, -> { where(global_status: 'picked_up')}
  scope :processing, -> { where(global_status: 'processing')}
  scope :deliverable, -> { where(global_status: %w[ready_for_delivery])}
  scope :delivered, -> { where(global_status: 'delivered')}
  scope :billable, -> { where(global_status: 'delivered')}
  scope :delayed, -> { where(global_status: 'delayed')}
  scope :reattemptable, -> { where(global_status: 'delayed_reattempt_delivery')}
  scope :cancelled, -> { where(global_status: 'cancelled')}
  scope :in_progress, -> { where.not(global_status: %w[cancelled delivered])}

  # alias for transaction
  belongs_to :client_transaction, foreign_key: 'transaction_id', class_name: "Transaction", optional: true
  belongs_to :client
  belongs_to :address
  belongs_to :partner_location, optional: true

  validates :pick_up_date, presence: true
  validates :pick_up_window, presence: true
  validates :full_address, presence: true
  validates :routable_address, presence: true
  validates :reference_code, presence: true
  validates :global_status, presence: true
  validates :client_price_per_pound, presence: true
  
  enum pick_up_window: %i[
    morning
    afternoon
  ]

  enum detergent: %i[
    hypoallergenic
  ]

  enum softener: %i[
    hypo_allergenic
  ]

  enum global_status: %i[
    created
    picked_up
    processing
    ready_for_delivery
    delivered
    delayed_reattempt_delivery
    cancelled
  ]

  enum courier_stated_delivered_location: %i[
    front_door
    back_door
    customer_or_household_member
    secure_mailroom
    secure_location
  ]

  enum problem_encountered: %i[
    nothing_to_pickup
    client_refused
    business_closed
    no_access
  ]

  # display
  def readable_pickup_window
    case pick_up_window
    when 'morning'
      '(7AM-10AM)'
    when 'afternoon'
      '(3PM-5PM)'
    end
  end

  def readable_detergent
    detergent.capitalize
  end

  def readable_softener
    softener.split('_').join('').capitalize
  end

  def readable_created_at
    created_at.strftime('%m/%d/%Y')
  end

  def readable_weight
    "#{format('%.2f', courier_weight)}lbs"
  end

  def formatted_pickup_time
    case pick_up_window
    when 'morning'
      '(7AM-10AM)'
    when 'afternoon'
      '(3PM-5PM)'
    else
      pick_up_window
    end
  end

  def google_nav_link
    formatted_link = []

    routable_address.split(',').each do |r|
      formatted_link.push(r.split(' ').join('+'))
    end
    # second slash is required to have the address be the destination instead of the origin
    @link = "https://www.google.com/maps/dir//#{formatted_link.join(',')}"
  end

  def formatted_appointment
		if pick_up_date.today?
			"Today at #{formatted_pickup_time}"
		else
			"#{pick_up_date.strftime('%m/%d/%Y')} at #{formatted_pickup_time}"
		end
	end

  # status updates
  def self.new_reference_code
    SecureRandom.hex(6)
  end

  def mark_picked_up
		update_attributes(
			global_status: 'picked_up',
			picked_up_from_client_at: DateTime.current
		)
  end

  def mark_received_by_partner
    self.update_attributes(
      global_status: 'processing',
      dropped_off_to_partner_at: DateTime.current
    )
  end

  def mark_picked_up_from_partner
		update_attributes(
      global_status: 'ready_for_delivery',
      picked_up_from_partner_at: DateTime.current
    )
  end

  def record_partner_weight(weight)
    update_attribute(:weight, weight)
  end
  
  def mark_delivered_to_client(delivery_location)
    update_attributes(
      global_status: 'delivered',
      delivered_to_client_at: DateTime.current,
      courier_stated_delivered_location: delivery_location
    )
  end

  def mark_paid
    update_attribute(:paid, true)
  end

  def mark_for_reattempt
    self.update_attributes(
      global_status: 'delayed_reattempt_delivery',
      deliver_to_customer_status: 'delivery_to_customer_not_started'
    )
  end

  def self.active_labels
    CommercialPickup.in_progress.pluck(:bags_code).compact
  end

  def save_new_label(code, bag_count)
		update_attributes(
			bags_collected: bag_count,
			bags_code: code
		)
  end
  
  def save_weight!(weight)
    update_attribute(:weight, weight)
  end

  def problem_cancel!(problem_encountered)
    update_attributes(
      global_status: 'cancelled',
      problem_encountered: problem_encountered
    )
  end

  def cancel!(problem_encountered)
    update_attributes(
        global_status: 'cancelled',
        problem_encountered: problem_encountered
    )
  end

  def startable?
    global_status != 'cancelled'
  end

  def refresh_pickup_directions
    update_attribute(:pick_up_directions, self.client.address.pick_up_directions)
  end

  def save_charge
    update_attributes(
      subtotal: subtotal,
      tax: tax,
      grandtotal: grandtotal,
      tax_rate: self.address.tax_rate,
      client_price_per_pound: client_price_per_pound
    )
  end

  def subtotal
    (((weight * self.client.price_per_pound) * 100).round / 100.00).to_d
  end 

  def grandtotal
    (([subtotal, tax].sum * 100).round / 100.00).to_d
  end

  def tax
    (((subtotal * address.tax_rate) * 100).round / 100.00).to_d
  end

  # DEBUG ONLY
  def reset_pickup_state!
    update_attributes(
      global_status: 'created',
      bags_code: nil,
      bags_collected: nil,
      picked_up_from_client_at: nil,
      dropped_off_to_partner_at: nil,
      picked_up_from_partner_at: nil,
      delivered_to_client_at: nil,
      weight: nil
    )
  end
end
