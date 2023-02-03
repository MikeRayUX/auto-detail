class WasherApplication
  include ActiveModel::Model
  attr_accessor :full_name,
                :email,
                :phone,
                :region_id,
                :live_within_region,
                :min_age,
                :legal_to_work,
                :has_equipment,
                :valid_drivers_license,
                :valid_car_insurance_coverage,
                :reliable_transportation,
                :valid_ssn,
                :can_lift_30_lbs,
                :has_disability,
                :unit_number,
                :city,
                :state,
                :zipcode,
                :street_address,
                :consent_to_background_check,
  # extracted models
  :washer, :address

  # washer
  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :region_id, presence: true

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

      @washer = Washer.new(
        password: @temp_password,
        password_confirmation: @temp_password,
        authenticate_with_otp: false,
        email: email.downcase,
        full_name: full_name,
        region_id: region_id,
        phone: phone,
        live_within_region: live_within_region == 'true' ? true : false,
        min_age: min_age == 'true' ? true : false,
        legal_to_work: legal_to_work == 'true' ? true : false,
        has_equipment: has_equipment == 'true' ? true : false,
        valid_drivers_license: valid_drivers_license == 'true' ? true : false,
        valid_car_insurance_coverage: valid_car_insurance_coverage == 'true' ? true : false,
        reliable_transportation: reliable_transportation == 'true' ? true : false,
        valid_ssn: valid_ssn == 'true' ? true : false,
        consent_to_background_check: consent_to_background_check == 'true' ? true : false,
        can_lift_30_lbs: can_lift_30_lbs == 'true' ? true : false,
        has_disability: has_disability == 'true' ? true : false
      )

      @washer.skip_finalized_washer_attributes = true

      @washer.save! 

      @address = @washer.create_address!(
        unit_number: unit_number,
        city: city,
        state: state,
        zipcode: zipcode,
        street_address: street_address
      )
      
    end
  end

  def region_has_capacity?
    @region = Region.find(region_id)

    unless @region.washers.activated.count < @region.washer_capacity
      flash[:error] = errors.add(:washer, "Region: #{@region.area.upcase} is not currently accepting Application")
      render :new
    end
  end

  def email_unique?
    unless Washer.where(email: email).none?
      errors.add(:email, 'has already been taken')
    end
  end

end