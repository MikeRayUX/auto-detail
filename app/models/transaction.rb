
# == Schema Information
#
# Table name: transactions
#
#  id                       :bigint           not null, primary key
#  order_id                 :bigint
#  user_id                  :bigint
#  paid                     :integer
#  stripe_customer_id       :string
#  card_brand               :string
#  card_exp_month           :string
#  card_exp_year            :string
#  card_last4               :string
#  customer_email           :string
#  order_reference_code     :string
#  subtotal                 :decimal(12, 2)
#  tax                      :decimal(12, 2)
#  grandtotal               :decimal(12, 2)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  stripe_response          :string
#  stripe_charge_id         :string
#  wash_hours_saved         :float
#  region_name              :string
#  tax_rate                 :float
#  weight                   :decimal(12, 2)
#  price_per_pound          :decimal(12, 2)
#  client_id                :bigint
#  start_date               :datetime
#  end_date                 :datetime
#  new_order_id             :string
#  new_order_reference_code :string
#  stripe_subscription_id   :string
#

class Transaction < ApplicationRecord
  scope :paid, -> { where(paid: 'paid') }
  scope :today, -> { where(created_at: Date.current.all_day)}
  scope :mtd, -> { where(created_at: Date.current.at_beginning_of_month..Date.current.end_of_day)}
  scope :ytd, -> {where(created_at: Date.current.at_beginning_of_year..Date.current.end_of_day)}

  belongs_to :order, optional: true
  belongs_to :user, optional: true
  belongs_to :client, optional: true
  has_many :commercial_pickups

  enum paid: %i[
    paid
    failed
    refunded
    retry_succeeded
    cannot_bill_maximum_retries_reached
  ]

  # validates :order, presence: true
  validates :paid, presence: true
  validates :card_brand, presence: true
  validates :card_exp_month, presence: true
  validates :card_exp_year, presence: true
  validates :card_last4, presence: true
  validates :customer_email, presence: true
  validates :subtotal, presence: true
  validates :tax, presence: true
  validates :grandtotal, presence: true
	validates :stripe_charge_id, presence: true
	validates :region_name, presence: true
  validates :tax_rate, presence: true

	def readable_created_at
		created_at.strftime('%m/%d/%y')
  end
    
  def readable_weight
    "#{format('%.2f', weight)} lbs"
  end

  def readable_subtotal
    "$#{format('%.2f', subtotal)}"
  end
  
  def readable_tax
    "$#{format('%.2f', tax)}"
  end

  def readable_grandtotal
    "$#{format('%.2f', grandtotal)}"
	end

	def readable_description
		"Order: #{order_reference_code}"
  end

  def readable_price_per_pound
    "$#{format('%.2f',  price_per_pound)} /lb"
  end

	def readable_payment_method
		"#{card_brand.upcase} ending in #{card_last4} (expires #{format('%02d', card_exp_month)}/#{card_exp_year})"
  end

  def condensed_payment_method
		"#{card_brand.upcase} ending in #{card_last4}"
  end
  
  def save_succeeded!(charge)
    assign_attributes(
      paid: 'paid',
      stripe_response: 'success',
      stripe_charge_id: charge.id
    )
    self.save!
  end

  def save_failed!(error)
    assign_attributes(
      paid: 'failed',
      stripe_charge_id: 'charge failed',
      stripe_response: error,
    )
    self.save!
  end

  def refund!
    Stripe::Refund.create(
      charge: stripe_charge_id
    )
   update_attribute(:paid, 'refunded')
  end

  def sum_paid_range(attribute, beginning_date, end_date)
    @collection = Transaction.where(paid: 'paid').where(created_at: Date.parse(beginning_date).beginning_of_day..Date.parse(end_date).end_of_day)

    @collection.sum(attribute.to_sym)
  end

  def display_date(date)
    date.strftime('%m/%d/%Y')
  end

  def date_range
    "#{display_date(start_date)} - #{display_date(end_date)}"
  end

  # REVENUE METRICS
  def self.revenue_today
    Transaction
      .today
      .paid
      .sum(:grandtotal)
      .round(2)
  end
  
  def self.revenue_mtd
    Transaction
      .mtd
      .paid
      .sum(:grandtotal)
      .round(2)
  end
  
  def self.revenue_ytd
    Transaction
      .ytd
      .paid
      .sum(:grandtotal)
      .round(2)
  end

  def self.average_purchase_value
    # total revenue / number of transactions/orders
    if Transaction.any?
      (Transaction
      .paid
      .sum(:grandtotal)
      .round / Transaction.count).round(2)
    else
      0
    end
  end

  def self.average_order_frequency_per_week
    # orders per week
    @frequency_collection = []
    @customers = User.joins(:orders)
    .group('users.id')
    .having('count(orders) > 1')

    if @customers.any?
      @customers.each do |customer|
        orders = customer.orders

        span_secs = orders.maximum(:created_at) - orders.minimum(:created_at)
        avg_secs = span_secs / (orders.count - 1)
        avg_days = avg_secs / (24 * 60 * 60)
        avg_in_week = avg_days / 7

        @frequency_collection.push(avg_in_week)
      end

      (@frequency_collection.sum / @customers.length).round(2)
    else
      0
    end
  end

  def self.average_customer_value_per_week
    avg_purchase_value = Transaction.average_purchase_value
    average_order_frequency_per_week = Transaction.average_order_frequency_per_week
    if average_purchase_value > 0 && average_order_frequency_per_week > 0
      (avg_purchase_value / average_order_frequency_per_week).round(2)
    else
      0
    end
  end

  def self.tax_collected_today
    Transaction
      .today
      .paid
      .sum(:tax)
      .round(2)
  end

  def self.tax_collected_mtd
    Transaction
      .mtd
      .paid
      .sum(:tax)
      .round(2)
  end

  def self.tax_collected_ytd
    Transaction
      .ytd
      .paid
      .sum(:tax)
      .round(2)
  end

  # mailers
  def send_payment_success_email!
    Commercial::Billing::PaymentReceiptMailer.send_email(self).deliver_later
  end

  def send_payment_failure_email!
    Commercial::Billing::PaymentFailedMailer.send_email(self).deliver_later
  end

end
