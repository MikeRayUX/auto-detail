# == Schema Information
#
# Table name: clients
#
#  id                 :bigint           not null, primary key
#  name               :string
#  email              :string
#  special_notes      :string
#  contact_person     :string
#  area_of_business   :string
#  pickup_window      :integer
#  card_brand         :string
#  card_exp_month     :string
#  card_exp_year      :string
#  card_last4         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  price_per_pound    :decimal(12, 2)
#  phone              :string
#  stripe_customer_id :string
#  monday             :boolean          default(FALSE)
#  tuesday            :boolean          default(FALSE)
#  wednesday          :boolean          default(FALSE)
#  thursday           :boolean          default(FALSE)
#  friday             :boolean          default(FALSE)
#  saturday           :boolean          default(FALSE)
#  sunday             :boolean          default(FALSE)
#  active             :boolean          default(TRUE)
#

class Client < ApplicationRecord
  scope :active, -> { where(active: true)}

  has_many :addresses
  has_many :commercial_pickups
  has_many :transactions

  before_save :sanitize_phone_number

  validates :name, presence: true
  validates :phone, presence: true, length: { minimum: 10, maximum: 16 }
  validates :contact_person, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :area_of_business, presence: true
  validates :pickup_window, presence: true
  validates :card_brand, presence: true
  validates :card_exp_month, presence: true
  validates :card_exp_year, presence: true
  validates :card_last4, presence: true
  validates :price_per_pound, presence: true

  enum pickup_window: %i[
    morning
    afternoon
  ]

  def send_new_client_email!
    Commercial::NewClientMailer.send_email(self).deliver_later
  end

  def within_region?
    self.address.region.present?
  end

  def region_name
		if self.within_region?
			self.address.region.area
		else
			"none"
		end
  end
  
  def tax_rate
		if self.within_region?
			self.address.region.tax_rate
		else
			0.085
		end
  end

  def readable_price_per_pound
    "$#{price_per_pound} /lb"
  end

  def current_usage
    if billable_pickups.any?
      billable_pickups.sum(:weight)
    else
      0
    end
  end

  def has_usage?
    current_usage > 0
  end

  def billable_pickups
    self.commercial_pickups.unpaid.delivered
  end

  def subtotal
    billable_pickups.sum(:subtotal)
  end

  def tax_total
    billable_pickups.sum(:tax)
  end

  def current_usage_grandtotal
    billable_pickups.sum(:grandtotal)
  end

  def readable_current_charge
   if subtotal > 0
    "$#{current_usage_grandtotal}"
   else
    "$0"
   end
  end

  def cancel_account!
    update_attribute(:active, false)
  end

  def pause_service!
    update_attribute(:active, false)
  end

  def charge_usage!
    Commercial::Clients::ChargeUsageWorker.perform_async(id)
  end

  PICKUP_CUTOFF_TIME = '5:00PM'
  def eligible_for_pickup_today?
    today_string = Date.current.strftime('%A').downcase
    self.read_attribute(today_string) && Time.parse(PICKUP_CUTOFF_TIME) > 45.minutes.from_now && self.active?
  end

  def create_stripe_customer!(card_params)
    @customer = Stripe::Customer.create(
      source: card_params[:stripe_token],
      email: email
    )

    update_attributes!(
      stripe_customer_id: @customer.id,
      card_brand: card_params[:card_brand],
      card_exp_month: card_params[:card_exp_month],
      card_exp_year: card_params[:card_exp_year],
      card_last4: card_params[:card_last4]
    )
  end

  def pickup_days
    [
      {
        day: 'mondays',
        pickup: monday
      },
      {
        day: 'tuesdays',
        pickup: tuesday
      },
      {
        day: 'wednesdays',
        pickup: wednesday
      },
      {
        day: 'thursdays',
        pickup: thursday
      },
      {
        day: 'fridays',
        pickup: friday
      },
      {
        day: 'saturdays',
        pickup: saturday
      },
      {
        day: 'sundays',
        pickup: sunday
      }
    ]
  end

  def readable_pickup_window
    case pickup_window
    when 'morning'
      "Morning (7am-10am)"
    when 'afternoon'
      "Afternoon (3pm-5pm)"
    when 'evening'
      "Evening (6pm-8pm)"
    end
  end

  def has_payment_method?
    stripe_customer_id.present?
  end

  def readable_payment_method
    "#{card_brand.upcase} Ending in #{card_last4}"
  end

  def readable_phone
    "(#{phone[0..2]})#{phone[3..5]}-#{phone[5..8]}"
  end

  private
  def sanitize_phone_number
		if self.phone.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
			self.phone = [$1, $2, $3].join("")
		end
  end
end
