# == Schema Information
#
# Table name: regions
#
#  id                      :bigint           not null, primary key
#  area                    :string
#  tax_rate                :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  washer_capacity         :integer          default(0)
#  price_per_bag           :decimal(12, 2)
#  washer_pay_percentage   :float
#  stripe_tax_rate_id      :string
#  last_washer_offer_check :datetime
#  max_concurrent_offers   :integer
#  failed_pickup_fee       :decimal(12, 2)
#  business_open           :string
#  business_close          :string
#

class Region < ApplicationRecord
	scope :with_washer_capacity, -> {where.not(washer_capacity: 0)}

	has_many :coverage_areas
	has_many :addresses
	has_many :workers
	has_many :washers
	has_many :new_orders
	
	validates :area, presence: true
	validates :price_per_bag, presence: true
	validates :tax_rate, presence: true
	validates :washer_pay_percentage, presence: true
	validates :stripe_tax_rate_id, presence: true
	validates :business_open, presence: true
	validates :business_close, presence: true


	def under_washer_capacity?
		washers.count < washer_capacity
	end

	def has_online_washers?
		self.washers.online.count > 0
	end

	def readable_business_hours
		"#{business_open}-#{business_close}"
	end

	def online_washers_count
		self.washers.online.count
	end

	def tax_rate_percentage
		(tax_rate * 100).round(2)	
	end

	def washer_ppb
		price_per_bag * self.washer_pay_percentage
	end

	def price_per_pound
		price_per_bag / 20
	end

	def calc_washer_pay(bag_count)
		((bag_count * self.price_per_bag) * self.washer_pay_percentage)
	end

	# ASAP AVAILABILITY
	def business_open?
		# true
		@open = Time.parse(business_open)
		@close = Time.parse(business_close)

		Time.current > @open && Time.current < @close
	end

	WASHERS_AVAILABLE_THRESHOLD = 24.hours
	def washer_open_offers_checked_recently?
		false
		# # true
		# last_washer_offer_check && 
		# (last_washer_offer_check > WASHERS_AVAILABLE_THRESHOLD.ago)
	end

	def refresh_last_washer_offer_check
		update(last_washer_offer_check: DateTime.current)
	end

end
