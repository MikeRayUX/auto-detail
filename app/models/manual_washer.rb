class ManualWasher
  include ActiveModel::Model
  attr_accessor :email,
                :payoutable_as_ic,
                :full_name,
                :first_name,
                :middle_name,
                :last_name,
                :region_id,
                :ssn,
                :date_of_birth,
                :phone,
                :drivers_license,
                :unit_number,
                :city,
                :state,
                :zipcode,
                :street_address,
  # extracted models
  :washer, :address

  # washer
  validates :payoutable_as_ic, presence: true
  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :middle_name, presence: true
  validates :last_name, presence: true
  validates :region_id, presence: true
  validates :ssn, presence: true
  validates :date_of_birth, presence: true
  validates :phone, presence: true
  validates :drivers_license, presence: true

  # address
  validates :street_address, presence: true, length: {
    maximum: 75 }

  validates :unit_number, length: {maximum: 20}
  validates :city, presence: true, length: {
    maximum: 100
  }
  validates :state, presence: true, length: {
    maximum: 100
  }
  validates :zipcode, presence: true, length: { minimum: 5,maximum: 5 }

  # custom validatons
  validate :email_unique?
  validate :region_has_capacity?

  def save
    if valid?
      @temp_password = Devise.friendly_token.first(6)

      @washer = Washer.create!(
        payoutable_as_ic: payoutable_as_ic == 'true' ? true : false,
        email: email.downcase,
        full_name: full_name,
        first_name: first_name,
        middle_name: middle_name,
        last_name: last_name,
        region_id: region_id,
        ssn: ssn,
        date_of_birth: date_of_birth,
        phone: phone,
        drivers_license: drivers_license,
        completed_app_intro_at: DateTime.current,
        tos_accepted_at: DateTime.current,
        eligibility_completed_at: DateTime.current,
        tax_agreement_accepted_at: DateTime.current,
        background_check_approved_at: DateTime.current,
        background_check_submitted_at: DateTime.current,
        insurance_agreement_accepted_at: DateTime.current,
        password: @temp_password,
        password_confirmation: @temp_password,
        authenticate_with_otp: false,
        stripe_account_id: payoutable_as_ic == 'true' ? nil : 'NOT_PAYOUTABLE'
      )

      @address = @washer.create_address!(
        unit_number: unit_number,
        city: city,
        state: state,
        zipcode: zipcode,
        street_address: street_address
      )

      # bypasses initial application questions
      @washer.update(
        live_within_region: true,
        min_age: true,
        legal_to_work: true,
        has_equipment: true,
        valid_drivers_license: true,
        valid_car_insurance_coverage: true,
        reliable_transportation: true,
        valid_ssn: true,
        consent_to_background_check: true,
        can_lift_30_lbs: true,
        has_disability: false
      )

      # invite washer with temp password
      @temp_password = Devise.friendly_token.first(6)
      @washer.assign_password(@temp_password)
      @washer.invite_for_onboard!(@temp_password)

      # activate
      @washer.initial_activate!
    end
  end

  def region_has_capacity?
    @region = Region.find(region_id)

    unless @region.washers.activated.count < @region.washer_capacity
      flash[:error] = errors.add(:washer, "Region: #{@region.area.upcase} does not have enough capacity to add another washer.")
      render :new
    end
  end

  def email_unique?
    unless Washer.where(email: email).none?
      errors.add(:email, 'has already been taken')
    end
  end

end