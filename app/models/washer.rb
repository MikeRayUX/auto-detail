# == Schema Information
#
# Table name: washers
#
#  id                              :bigint           not null, primary key
#  email                           :string           default(""), not null
#  encrypted_password              :string           default(""), not null
#  reset_password_token            :string
#  reset_password_sent_at          :datetime
#  remember_created_at             :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  first_name                      :string
#  middle_name                     :string
#  last_name                       :string
#  region_id                       :bigint
#  encrypted_ssn                   :string
#  encrypted_ssn_iv                :string
#  encrypted_date_of_birth         :string
#  encrypted_date_of_birth_iv      :string
#  encrypted_phone                 :string
#  encrypted_phone_iv              :string
#  deactivated_at                  :datetime
#  activated_at                    :datetime
#  otp_secret_key                  :string
#  authenticate_with_otp           :boolean          default(TRUE)
#  encrypted_drivers_license       :string
#  encrypted_drivers_license_iv    :string
#  completed_app_intro_at          :datetime
#  tos_accepted_at                 :datetime
#  eligibility_completed_at        :datetime
#  background_check_submitted_at   :datetime
#  stripe_account_id               :string
#  tax_agreement_accepted_at       :datetime
#  background_check_approved_at    :datetime
#  insurance_agreement_accepted_at :datetime
#  full_name                       :string
#  last_online_at                  :datetime
#  current_lat                     :float
#  current_lng                     :float
#  payoutable_as_ic                :boolean          default(TRUE)
#  live_within_region              :boolean
#  min_age                         :boolean
#  legal_to_work                   :boolean
#  valid_drivers_license           :boolean
#  valid_car_insurance_coverage    :boolean
#  valid_ssn                       :boolean
#  reliable_transportation         :boolean
#  can_lift_30_lbs                 :boolean
#  has_disability                  :boolean
#  has_equipment                   :boolean
#  consent_to_background_check     :boolean
#  app_invitation_sent_at          :datetime
#

class Washer < ApplicationRecord
  attr_accessor :skip_finalized_washer_attributes

  scope :activated, -> {where.not(activated_at: nil).where(deactivated_at: nil)}
  scope :inactive, -> {where(activated_at: nil)}
  scope :deactivated, -> {where.not(deactivated_at: nil)}
  scope :online, -> {where.not(activated_at: nil).where(deactivated_at: nil).where("last_online_at > ?", WorkSession::REFRESH_LIMIT.minutes.ago)}
  scope :offline, -> {where.not(activated_at: nil).where(deactivated_at: nil).where("last_online_at < ?", WorkSession::REFRESH_LIMIT.minutes.ago)}

  attr_encrypted :ssn, key: ATTR_ENCRYPTED_KEY
  attr_encrypted :date_of_birth, key: ATTR_ENCRYPTED_KEY
  attr_encrypted :phone, key: ATTR_ENCRYPTED_KEY
  attr_encrypted :drivers_license, key: ATTR_ENCRYPTED_KEY

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,  :recoverable, :rememberable, :validatable

  before_save :format_attributes

  has_one_time_password
  has_one :address
  has_many :new_orders
  has_many :work_sessions
  has_many :offer_events
  has_many :support_tickets
  has_many :email_sends
  belongs_to :region, optional: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :phone, presence: true, length: { minimum: 10, maximum: 16 }

  validates :full_name, presence: true

  validates :first_name, presence: true, unless: :skip_finalized_washer_attributes

  validates :last_name, presence: true, unless: :skip_finalized_washer_attributes
  
  validates :ssn, presence: true, length: {
    minimum: 11, max: 11
  }, unless: :skip_finalized_washer_attributes

  # validate :old_enough?, unless: :skip_finalized_washer_attributes
  
  validates :date_of_birth, presence: true, length: { minimum: 10, maximum: 10 }, unless: :skip_finalized_washer_attributes

  validates :drivers_license, presence: true, unless: :skip_finalized_washer_attributes

  def abbrev_name
    "#{first_name} #{last_name.first}."
  end

  def alt_full_name
    [first_name, middle_name, last_name].compact.join(',')
  end

  def summed_earnings(collection)
    "#{format('%.2f', collection.sum(:washer_final_pay).round(2))}"
  end

  def disable_authenticate_with_otp
    self.skip_finalized_washer_attributes = true
    update(authenticate_with_otp: false)
  end

  def enable_authenticate_with_otp
    self.skip_finalized_washer_attributes = true
    update(authenticate_with_otp: true)
  end

  def refresh_online_status
    update_attribute(:last_online_at, DateTime.current)
  end

  def go_online
    update_attribute(:last_online_at, DateTime.current)

    @session = self.work_sessions.create!(
      last_checked_in_at: DateTime.current,
      secure_id: SecureRandom.hex(3)
    )

    @session
  end

  def application_eligible?
    live_within_region &&
    min_age &&
    legal_to_work &&
    has_equipment &&
    valid_drivers_license &&
    valid_car_insurance_coverage &&
    reliable_transportation &&
    valid_ssn &&
    consent_to_background_check &&
    can_lift_30_lbs &&
    !has_disability
  end

  # def go_offline
  #   update_attribute(:last_online_at, nil)
  # end

  # def is_online?
  #   last_online_at && last_online_at > WorkSession::REFRESH_LIMIT.minutes.ago
  # end

  def under_max_concurrent_asap_offers?
    new_orders.in_progress.count < region.max_concurrent_offers
  end

  # def is_offline?
  #   !last_online_at || last_online_at < WorkSession::REFRESH_LIMIT.minutes.ago
  # end 

  # def kill_active_sessions!
  #   work_sessions.refreshable.each do |s|
  #     s.terminate!
  #   end
  # end

  def update_location(lat, lng)
    update(
      current_lat: lat,
      current_lng: lng
    )
  end

  # AUTH START
  def activated?
    activated_at && !deactivated_at
  end
  
  def invited?
    app_invitation_sent_at && eligibility_completed_at
  end 

  def completed_eligibility_application?
    eligibility_completed_at
  end
  # AUTH END
  
  def activatable?
    !activated_at || !deactivated_at
  end

  def deactivated?
    activated_at && deactivated_at
  end

  def deactivatable?
    activated_at && !deactivated_at
  end

  def not_deactivated?
    !deactivated_at
  end

  def reactivateable?
    activated_at && deactivated_at
  end

  def initially_activatable?
    completed_activation_steps? 
    # completed_activation_steps? && valid_stripe_connect_acount?
  end

  def initially_activated?
    activated_at.present?
  end

  def not_initially_activated?
    !activated_at
  end

  def activate!
    update(activated_at: DateTime.current, deactivated_at: nil)
  end

  # only use for FIRST activation, use reactivate!/deactivate! to control bans/unbans
  def initial_activate!
    update(activated_at: DateTime.current)
  end
  
  def reactivate!
    update(deactivated_at: nil)
  end
  
  def deactivate!
    update(deactivated_at: DateTime.current, last_online_at: nil)
  end

  def completed_activation_steps?
    application_completed? &&
    invited_to_app? &&
    completed_app_intro_at.present? && 
    tos_accepted_at.present? &&
    background_check_submitted? &&
    insurance_agreement_accepted_at.present? &&
    tax_agreement_accepted_at.present? &&
    stripe_account_id.present?
  end

  def application_completed?
    full_name &&
    email &&
    phone &&
    live_within_region != nil &&
    min_age != nil &&
    legal_to_work != nil &&
    has_equipment != nil &&
    valid_drivers_license != nil &&
    valid_car_insurance_coverage != nil &&
    reliable_transportation != nil &&
    valid_ssn != nil &&
    can_lift_30_lbs != nil &&
    has_disability != nil &&
    consent_to_background_check &&
    address.present? &&
    region.present? &&
    address.street_address &&
    address.unit_number &&
    address.city &&
    address.state &&
    address.zipcode
  end

  def invited_to_app?
    eligibility_completed_at &&
    app_invitation_sent_at?
  end

  def background_check_submitted?
    background_check_submitted_at &&
    first_name &&
    last_name &&
    ssn &&
    date_of_birth &&
    phone &&
    drivers_license &&
    address.present? &&
    region.present? &&
    address.street_address &&
    address.unit_number &&
    address.city &&
    address.state &&
    address.zipcode
  end

  def activation_status
    if self.activated?
      'Activated'
    elsif self.deactivated?
      'Deactivated'
    elsif self.completed_activation_steps?
      'Pending Approval'
    else
      'Incomplete'
    end
  end

  # app intro START
  def not_completed_app_intro?
    !completed_app_intro_at
  end

  def completed_app_intro?
    completed_app_intro_at
  end

  def app_intro_status
    if completed_app_intro?
      {
        status: 'complete',
        enabled: false ,
        message: ''
      }
    else
      {
        status:  'incomplete',
        enabled: true,
        message: ''
      }
    end
  end

  def complete_app_intro!
    update_attribute(:completed_app_intro_at, DateTime.current)
  end
  # app intro END

  # tos START
  def not_accepted_tos?
    !tos_accepted_at
  end

  def accepted_tos?
    tos_accepted_at
  end

  def tos_status
    if accepted_tos?
      {
        status: 'complete' ,
        enabled: false,
        message: ''
      }
    else
      {
        status: 'incomplete' ,
        enabled: true,
        message: ''
      }
    end
  end

  def accept_tos!
    update_attribute(:tos_accepted_at, DateTime.current)
  end
  # tos END

  # eligibility START
  def not_completed_eligibility_application?
    !eligibility_completed_at
  end

  def eligibility_application_status
    if completed_eligibility_application?
      {
        status: 'complete',
        enabled: false ,
        message: ''
      }
    else
      {
        status:  'incomplete',
        enabled: true,
        message: ''
      }
    end
  end

  def complete_eligibility_application!
    update(eligibility_completed_at: DateTime.current)
  end

  def completed_eligibility_application?
    eligibility_completed_at
  end

  def invite_for_onboard!(temp_password)
    update(
      eligibility_completed_at: DateTime.current,
      app_invitation_sent_at: DateTime.current
    )
    self.send_invitation_email!(temp_password)
  end

  # eligibility END

  # background check START
  def not_submitted_background_check?
    !self.background_check_submitted_at
  end

  def submitted_background_check?
    self.background_check_submitted_at
  end

  def background_check_pending_approval?
    self.background_check_submitted_at && 
    !self.background_check_approved_at
  end

  def background_check_approved?
    self.background_check_submitted_at && 
    self.background_check_approved_at
  end

  def background_check_status
    @status = {
      status:  '',
      enabled: false,
      message: ''
    }

    if self.not_submitted_background_check?
      @status[:status] = 'incomplete'
      @status[:enabled] = true
    end

    if self.background_check_pending_approval?
      @status[:status] = 'pending'
      @status[:enabled] = false
      @status[:message] = "Submitted on #{self.background_check_submitted_at.strftime('%m/%d/%Y')}"
    end

    if self.background_check_approved?
      @status[:status] = 'complete'
      @status[:enabled] = false
      @status[:message] = "Approved on #{self.background_check_approved_at.strftime('%m/%d/%Y')}"
    end

    @status
  end

  def mark_background_check_submitted!
    update_attribute(:background_check_submitted_at, DateTime.current)
  end

  def approve_background_check!
    update_attribute(:background_check_approved_at, DateTime.current)
  end

  def undo_background_check_approval!
    update_attribute(:background_check_approved_at, nil)
  end
  # background check END

  # tax agreement START
  def not_accepted_tax_agreement?
    !tax_agreement_accepted_at
  end

  def tax_agreement_status
    if tax_agreement_accepted_at
      {
        status: 'complete',
        enabled: false,
        message: ''
      }
    else
      {
        status:  'incomplete',
        enabled: true,
        message: ''
      }
    end
  end

  def accept_tax_agreement!
    update_attribute(:tax_agreement_accepted_at, DateTime.current)
  end
  # tax agreement END

  # insurance agreement START
  def not_accepted_insurance_agreement?
    !insurance_agreement_accepted_at
  end

  def insurance_agreement_status
    if insurance_agreement_accepted_at
      {
        status: 'complete',
        enabled: false,
        message: ''
      }
    else
      {
        status:  'incomplete',
        enabled: true,
        message: ''
      }
    end
  end

  def accept_insurance_agreement!
    update_attribute(:insurance_agreement_accepted_at, DateTime.current)
  end
  # insurance agreement END

  def abandon_offer(offer)
    offer.update(
      status: 'created',
      washer_id: nil
    )
  end

  # stripe connect START
  def no_stripe_account?
    !stripe_account_id
  end

  def create_stripe_account!
    @account = Stripe::Account.create({
      type: 'express',
      country: 'US',
      email: self.email,
      capabilities: {
        transfers: {requested: true},
        tax_reporting_us_1099_misc: {requested: true}
      }
    })
    self.skip_finalized_washer_attributes = true
    self.update_attribute(:stripe_account_id, @account.id)
  end

  def stripe_account_status
    @status = {
      status: 'incomplete',
      enabled: true,
      message: ''
    }
    if stripe_account_id && valid_stripe_connect_acount?
      @status[:status] = 'complete'
      @status[:enabled] = false
    else
      @status[:status] = 'incomplete'
      @status[:enabled] = true
    end

    @status
  end

  def valid_stripe_connect_acount?
    if !payoutable_as_ic
      true
    else
      stripe_account_id && Stripe::Account.retrieve(stripe_account_id)['charges_enabled'] == true
    end
  end

  def requires_stripe_setup?
    Stripe::Account.retrieve(stripe_account_id)['charges_enabled'] == false
  end

  def new_stripe_setup_link
    if Rails.env.production?
      @base_url = "https://www.freshandtumble.com/washers/stripe_connect"
    else
      @base_url = "http://localhost:3000/washers/stripe_connect"
    end

    @link = Stripe::AccountLink.create({
      account: stripe_account_id,
      refresh_url: @refresh_url = "#{@base_url}/refreshes?id=#{stripe_account_id}",
      return_url: @return_url = "#{@base_url}/returns?id=#{stripe_account_id}",
      type: 'account_onboarding',
    })['url']
  end
  # stripe connect END

  def assign_password(password)
    update(
      password: password,
      password_confirmation: password
    )
  end

  def formatted_phone
    ApplicationHelper::Helpers.number_to_phone(phone, area_code: true)
  end

  def format_attributes
    if self.skip_finalized_washer_attributes
      self.email = email.downcase
    else
      [email, first_name, middle_name, last_name, email].each do |a|
        a = a.downcase
      end
  
      if self.phone.gsub(/\D/, "").match(/^1?(\d{3})(\d{3})(\d{4})/)
        self.phone = [$1, $2, $3].join("")
      end
    end
  end

  def combined_name
    [first_name, middle_name, last_name].compact.join(' ')
  end

  def formatted_phone
    ApplicationHelper::Helpers.number_to_phone(phone, area_code: true)
  end

  # mailers
  def send_one_time_password_email!
    # used to confirm email after creating account
    Washers::OneTimePasswordMailer.send_email(self).deliver_later
  end

  RESET_PASSWORD_TIME_LIMIT = 10.minutes
  def send_forgot_password_email!
    # used to confirm email after creating account
    Washers::ForgotPasswordMailer.send_email(self).deliver_later
  end 

  def send_application_received_email!
    Washers::ApplicationReceivedMailer.send_email(self, region).deliver_later
  end

  def send_invitation_email!(temp_password)
    Washers::InvitationMailer.send_email(self, temp_password).deliver_later
  end

  def send_initial_activation_email!
    Washers::InitialActivationMailer.send_email(self).deliver_later
  end 

  # custom validations
  # user agrees to being 21 or older on initial account creation so this may not be needed
  # def old_enough?
  #   unless (Date.parse(date_of_birth) + 21.years) < Date.current
  #     errors.add(:washer, 'You must be 21 or over to complete this application.')
  #   end
  # end
	
  # DEBUG
  def reset!
    self.skip_finalized_washer_attributes = true
    if self.address.present?
      self.address.destroy
    end
    update(
      activated_at: nil,
      deactivated_at: nil,
      first_name: nil,
      last_name: nil,
      ssn: nil,
      date_of_birth: nil,
      phone: nil,
      drivers_license: nil,
      stripe_account_id: nil,
      completed_app_intro_at: nil,
      tos_accepted_at: nil,
      insurance_agreement_accepted_at: nil,
      eligibility_completed_at: nil,
      background_check_submitted_at: nil,
      background_check_approved_at: nil,
      tax_agreement_accepted_at: nil
    )
  end

  def temp_deactivate
    deactivate!
    sleep 6.seconds
    activate!
  end

  def undo_background_check_application!
    update!(
      background_check_submitted_at: nil
    )
    address.destroy!
  end

  def drop_offers!
    if new_orders.any?
      new_orders.all.each do |o|
        o.update(
          # accept_by: DateTime.current + ACCEPT_LIMIT,
          # created_at: DateTime.current,
          # est_pickup_by: DateTime.current + ACCEPT_LIMIT,
          washer_id: nil,
          status: 'created',
          enroute_for_pickup_at: nil,
          picked_up_at: nil,
          completed_at: nil,
          enroute_for_delivery_at: nil,
          delivered_at: nil
        )
      end
    end
  end

end
