# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  card_brand                :string
#  card_exp_month            :string
#  card_exp_year             :string
#  card_last4                :string
#  stripe_customer_id        :string
#  phone                     :string
#  full_name                 :string
#  deleted_at                :datetime
#  sms_enabled               :boolean          default(TRUE)
#  promotional_emails        :boolean          default(TRUE)
#  business_review_left      :boolean          default(FALSE)
#  stripe_subscription_id    :string
#  subscription_activated_at :datetime
#  subscription_expires_at   :datetime
#  otp_secret_key            :string
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :registerable
  #  :confirmable

  scope :newest, -> {order(created_at: :desc)}
  scope :oldest, -> {order(created_at: :asc)}
  scope :active, -> { where(deleted_at: nil)}
  scope :cancelled, -> { where.not(deleted_at: nil)}
  scope :today, -> { where(created_at: Date.current.all_day)}
  scope :mtd, -> { where(created_at: Date.current.at_beginning_of_month..Date.current.end_of_day)}
  scope :ytd, -> {where(created_at: Date.current.at_beginning_of_year..Date.current.end_of_day)}

  RESET_PASSWORD_TIME_LIMIT = 10.minutes

  has_one_time_password
  has_one :address
  has_many :orders
  has_many :new_orders
  has_many :transactions
  has_many :notifications
  has_many :questionaires
  has_many :support_tickets
  has_many :email_sends

	before_save :downcase_full_name
	before_save :sanitize_phone_number

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  validates :full_name, presence: true, length: { maximum: 75 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { minimum: 10, maximum: 16 }

  def send_forgot_password_email!
    # used to confirm email after creating account
    Users::ForgotPasswordMailer.send_email(self).deliver_later
  end 

  def soft_delete
    update_attribute(:deleted_at, DateTime.current)
  end

  def ban!
    update_attribute(:deleted_at, DateTime.current)
  end

  def unban!
    update_attribute(:deleted_at, nil)
  end

  def active_for_authentication?
    super && !deleted_at
  end

  def inactive_message
    'Sorry, this account has been cancelled.'
	end
	
  def eligible_for_review_request?
	self.orders.delivered.count >= 1 && !business_review_left
  end

  def request_business_review!
    if self.eligible_for_review_request?
        AskForReviewMailer.send_email(self).deliver_now
    end
  end

  def formatted_name
    @full_name = full_name.split(' ').each do |n|
      n.capitalize!
    end
    @full_name.join(' ')
	end
	
	def first_name
    formatted_name.split.first
  end

  def readable_created_at
    created_at.strftime('%m/%d/%Y at %I:%M%P')
	end

	def within_region?
		self.address.region.present?
  end
  
  def region
    self.address.region
  end

  def tax_rate
    if self.within_region?
        self.address.region.tax_rate
    else
        0.085
    end
  end
	
  def region_name
    if self.within_region?
        self.address.region.area
    else
        "none"
    end
  end

  def full_address
    address.full_address
  end

  def routable_address
    address.address
  end
	
  def waiting_for_delivery_reattempts?
      self.orders.reattemptable.any?
  end

  def update_reattempts_with_new_address
      self.orders.reattemptable.update_all(
          full_address: self.address.full_address,
          routable_address: self.address.address
      )
  end

  def not_ordered_yet?
      self.orders.none?
  end
  
  def first_order?
    self.orders.count == 1
  end

  def repeat_customer?
    orders.delivered.count > 0
  end

  def formatted_phone
    ApplicationHelper::Helpers.number_to_phone(phone, area_code: true)
  end

  def completed_setup?
    address.present?
  end

  def owns_order?(reference_code)
    self.orders.find_by(reference_code: reference_code).present?
  end

  def within_service_area?
    CoverageArea.where(zipcode: self.address.zipcode).any?
  end

  def completed_preferences_setup?
    user_preference.present?
  end

  def has_payment_method?
    stripe_customer_id.present?
  end

  def no_payment_method?
    stripe_customer_id.blank?
  end

  def create_stripe_customer!(card_params)
    @customer = Stripe::Customer.create(
      source: card_params[:stripe_token],
      email: email
    )

    update(
      stripe_customer_id: @customer.id,
      card_brand: card_params[:card_brand],
      card_exp_month: card_params[:card_exp_month],
      card_exp_year: card_params[:card_exp_year],
      card_last4: card_params[:card_last4]
    )
  end

  def has_active_subscription?
    stripe_subscription_id &&
    subscription_activated_at &&
    subscription_expires_at &&
    (subscription_expires_at > DateTime.current)
  end

  def subscription_status
    if !stripe_subscription_id
      'NOT SUBSCRIBED'
    elsif subscription_expired?
      'EXPIRED'
    else
     "EXPIRES: #{readable_subscription_expiry}"
    end 
  end

  def subscription_expired?
    stripe_subscription_id &&
    subscription_activated_at &&
    subscription_expires_at &&
    (subscription_expires_at < DateTime.current)
  end

  def activate_subscription!(subscription)
    @sub = Stripe::Subscription.create({
      customer: self.stripe_customer_id,
      default_tax_rates: [self.address.region.stripe_tax_rate_id],
      items: [
        {price: subscription.stripe_price_id},
      ],
    })

    self.update(
      stripe_subscription_id: @sub.id, 
      subscription_activated_at: Time.at(@sub.current_period_start),
      subscription_expires_at: Time.at(@sub.current_period_end)
    )

    @region = self.address.region

    self.transactions.create!(
      stripe_customer_id: stripe_customer_id,
      stripe_subscription_id: @sub.id,
      stripe_charge_id: @sub.id,
      paid: 'paid',
      card_brand: card_brand,
      card_exp_month: card_exp_month,
      card_exp_year: card_exp_year,
      card_last4: card_last4,
      customer_email: email,
      subtotal: subscription.price,
      tax: subscription.tax(@region.tax_rate),
      tax_rate: @region.tax_rate,
      grandtotal: subscription.grandtotal(@region.tax_rate),
      region_name: @region.area
    )
  end

  def extend_subscription!(period_start, period_end)
    update(
      subscription_activated_at: Time.at(period_start),
      subscription_expires_at: Time.at(period_end)
    )
  end

  def cancel_subscription!
    Stripe::Subscription.delete(stripe_subscription_id)

    update(
      stripe_subscription_id: nil,
      subscription_activated_at: nil,
      subscription_expires_at: nil,
    )
  end

  def send_subscription_email!
    Users::SubscriptionCreateMailer.send_email(self).deliver_later
  end

  def send_subscription_payment_failed_email!
    Users::SubscriptionPaymentFailedMailer.send_email(self).deliver_later
  end

  def send_subscription_payment_dead_email!
    Users::SubscriptionPaymentDeadMailer.send_email(self).deliver_later
  end

  def send_subscription_cancel_email!
    Users::SubscriptionCancelMailer.send_email(self).deliver_later
  end

  def next_subscription_renewell_date
    (subscription_activated_at + 1.month).strftime('%m/%d/%Y')
  end

  def readable_subscription_expiry
    subscription_expires_at.strftime('%m/%d/%Y')
  end

  def readable_subscription_activated_at
    subscription_activated_at.strftime('%m/%d/%Y')
  end

  def readable_subscription_renewell_date
    (subscription_activated_at + 1.month).strftime('%m/%d/%Y')
  end

  def update_stripe_payment_method(card_params)
    Stripe::Customer.update(
      stripe_customer_id,
      source: card_params[:stripe_token]
    )
    update_attributes!(
      card_brand: card_params[:card_brand],
      card_exp_month: card_params[:card_exp_month],
      card_exp_year: card_params[:card_exp_year],
      card_last4: card_params[:card_last4]
    )
  end

  def update_stripe_customer_email
    Stripe::Customer.update(
      stripe_customer_id,
      email: email
    )
    rescue Stripe::InvalidRequestError => e
      false
  end

  def readable_payment_method
    "#{card_brand.upcase} ENDING IN #{card_last4}"
  end
  
  def payment_method
    "#{card_brand.upcase}...#{card_last4} expires #{card_exp_month}/#{card_exp_year}"
  end

	def new_transaction(order, pricing, subtotal, tax, grandtotal)
		self.transactions.new(
      order_id: order.id,
      order_reference_code: order.reference_code,
      stripe_customer_id: self.stripe_customer_id,
      card_brand: self.card_brand,
      card_exp_month: self.card_exp_month,
      card_exp_year: self.card_exp_year,
      card_last4: self.card_last4,
      customer_email: self.email,
      price_per_pound: pricing.price_per_pound,
      weight: order.courier_weight,  
      subtotal: subtotal,
			tax: tax,
			wash_hours_saved: order.wash_hours_saved,
			grandtotal: grandtotal,
			tax_rate: self.tax_rate,
			region_name: self.region_name
    )
	end

  def send_welcome_email!
    Users::NewUserMailerWorker.perform_async(id)
  end

	def send_sms_notification!(event, new_order, message_body)
    if sms_enabled
      SmsNotificationWorker.perform_async(self.id, event, new_order.id, message_body)
    end
	end

	# MARKETING EMAILS UNSUSBCRIBE
	# access token for unsubscribe
	def unsub_token
		User.create_unsub_token(self)
	end

	# class method for token generation
	def self.create_unsub_token(service_area_mailing_list)
		verifier.generate(service_area_mailing_list.id)
	end

	# verifier based on application secret
	def self.verifier
		key_base = Rails.application.credentials.marketing_emails[:secret_key_base]
		ActiveSupport::MessageVerifier.new(key_base)
	end

	# get User from a token
	def self.read_unsub_token(token)
		id = verifier.verify(token)
		User.find(id)
		rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
	end

	def unsubscribe_from_promotional_emails!
		update_attribute :promotional_emails, false
	end

	def unsubscribed?
		promotional_emails == false
  end

  def self.should_not_receive_marketing_emails
    User.where(promotional_emails: false)
  end

  def self.eligible_for_marketing_emails
    User.where(deleted_at: nil).where(promotional_emails: true)
  end

  # def send_sendgrid_email_from_template!(template_id)
  #   Users::SendgridTemplateMailerWorker.perorm_async(self.id, template_id)
  # end

  def self.clear_sendgrid_contacts!
    HTTParty.delete(
      SENDGRID_MARKETING_URL, 
      headers: SENDGRID_HEADERS,
      query: {
        'delete_all_contacts': 'true'
      } 
    )
  end

  def self.update_sendgrid_contacts!
    eligible_users = User.eligible_for_marketing_emails
    users = []

    if eligible_users.any?
      eligible_users.each do |u|
        users.push({email: u.email})
        contacts = {
          contacts: users
        }
    
        response = HTTParty.put(
            SENDGRID_MARKETING_URL, 
            headers: SENDGRID_HEADERS,
            body: contacts.to_json
          )
      end
    end
  end

  # metrics

  def self.global_count
    User
      .all
      .count
  end

  def orders_count
    self.orders.count
  end

  def self.users_today_count
    User
      .active
      .today
      .count
  end

  def self.mtd_order_latest
    User
      .active
      .mtd
      .order('created_at DESC')
  end

  def self.users_mtd_count
    User
      .active
      .mtd
      .count
  end

  def self.users_ytd_count
    User
      .active
      .ytd
      .count
  end

  def self.global_customer_count
    @customer_count = Order
      .delivered
      .having('count(user_id) >= 1')
      .group('user_id')
      .pluck('user_id')
      .count

    "#{@customer_count}/#{User.global_count}"
  end

  def self.customer_today_count
    User
      .active
      .where(created_at: Date.current.all_day)
      .count
  end
  
  def self.customer_mtd_count
    User
      .active
      .where(created_at: Date.current.at_beginning_of_month..Date.current.end_of_day)
      .count
  end

  def self.active_customer_count
    User
      .active
      .joins(:new_orders).group('users.id')
      .where(new_orders: {status: 'delivered'})
      .where(new_orders: {created_at: (Date.current - 14.days)..Date.current.end_of_day})
      .having('count(new_orders) >= 1')
      .group('user_id')
      .pluck('user_id')
      .count
  end

  def self.average_order_frequency
    @frequency_collection = []
    @customers = User.joins(:new_orders)
    .group('users.id')
    .having('count(new_orders) > 1') 

    if @customers.any?
      @customers.each do |customer|
        new_orders = customer.new_orders

        span_secs = new_orders.maximum(:created_at) - new_orders.minimum(:created_at)
        avg_secs = span_secs / (new_orders.count - 1)
        avg_days = avg_secs / (24 * 60 * 60)

        @frequency_collection.push(avg_days)
      end

      "#{(@frequency_collection.sum / @customers.length).round(2)} days"
    else
      "none to show"
    end
  end

  def self.stale_customer_count
    User.joins(:orders).group('users.id')
    .where(orders: {global_status: 'delivered'})
    .where(orders: {created_at: Date.current.at_beginning_of_year..(Date.current - 14.days)})
    .having('count(orders) >= 1')
    .group('user_id')
    .pluck('user_id')
    .count
  end

  def self.global_customer_to_order_rate
    @customer_count = User.global_customer_count
    @total_users = User.global_count
    @percentage = ((@customer_count.to_f / @total_users.to_f) * 100).round

    "%#{@percentage} order rate"
  end

  def self.cancelled_account_count
    User
      .where
      .not(deleted_at: nil)
      .count
  end

  # debug
  def reset_stripe!
    update(
      stripe_customer_id: nil,
      stripe_subscription_id: nil,
      subscription_activated_at: nil,
      subscription_expires_at: nil
    )
  end

  def delete_stripe_payment_method
    p "#{'*' * rand(1..10)} DELETING STRIPE PAYMENT METHOD..."
    @customer = Stripe::Customer.retrieve(self.stripe_customer_id)

    p @customer
  
    Stripe::Customer.delete_source(
      self.stripe_customer_id,
      @customer.sources.data.first.id
    )
  
    p "#{'*' * rand(1..10)} STRIPE PAYMENT METHOD DELETED"
    rescue Stripe::StripeError => e
      p 'delete_stripe_payment_method'
      p e
  end

  def expire_sub!
    update(
      stripe_subscription_id: 'asdfasdfasdfsad',
      subscription_activated_at: DateTime.current - 1.month,
      subscription_expires_at: DateTime.current - 1.days
    )
  end

  private

  def downcase_full_name
    full_name.downcase!
	end
	
	def sanitize_phone_number
		if self.phone.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
			self.phone = [$1, $2, $3].join("")
		end
  end
end
