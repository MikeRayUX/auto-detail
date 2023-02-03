class NewWasher
  include ActiveModel::Model

  attr_accessor :email,
                :first_name,
                :middle_name,
                :last_name,
                :phone,
                :date_of_birth,
                :ssn,
                :street_address,
                :unit_number,
                :city,
                :state,
                :zipcode,
  # extracted models
  :washer, :address

  # WASHER
  validate :email_unique?
  validate :old_enough?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { minimum: 10, maximum: 16 }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :ssn, presence: true, length: {
    minimum: 11, max: 11
  }
  validates :date_of_birth, presence: true, length: { minimum: 10, maximum: 10 }

  # ADDRESS
  validate :within_region?
  validates :street_address, presence: true, length: {
    maximum: 75
  }
  validates :unit_number,
            length: {
              maximum: 20
            }

  validates :city, presence: true, length: {
    maximum: 100
  }
  validates :state, presence: true, length: {
    maximum: 100
  }
  validates :zipcode, presence: true, length: { minimum: 5,
                                                maximum: 5 }

  def save
    @temp_password = Devise.friendly_token.first(6)
    @region = CoverageArea.find_by(zipcode: zipcode).region
    @washer = Washer.create!(
      email: email,
      first_name: first_name, 
      middle_name:middle_name,
      phone: phone,
      last_name: last_name,
      date_of_birth: date_of_birth,
      ssn: ssn,
      password: @temp_password,
      password_confirmation: @temp_password,
      region_id: @region.id
    )
    @washer.create_address!(
      street_address: street_address,
      unit_number: unit_number,
      city: city,
      state: state,
      zipcode: zipcode,
      region_id: @region.id
    )
  end

  # washer
  def email_unique?
    unless Washer.where(email: email.downcase).none?
      errors.add(:email, 'has already been taken')
    end
  end

  def old_enough?
    unless (Date.parse(date_of_birth) + 21.years) < Date.current
      errors.add(:washer, 'You must be 21 or over to complete this application.')
    end
  end

  # address
  def within_region?
    @coverage_area = CoverageArea.find_by(zipcode: zipcode)
    unless @coverage_area.present? && @coverage_area.within_region?
      errors.add(:address, "We're sorry, we currently don't have any availability within the address that you specified. Please try again later.")
    end
  end
  
end