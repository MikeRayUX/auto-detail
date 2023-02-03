class NewClient
  include ActiveModel::Model
  attr_accessor :name, 
                :phone, 
                :email, 
                :special_notes, 
                :contact_person, 
                :area_of_business, 
                :monday, 
                :tuesday, 
                :wednesday, 
                :thursday, 
                :friday, 
                :saturday, 
                :sunday, 
                :pickup_window, 
                :stripe_token, 
                :card_brand, 
                :card_exp_month, 
                :card_exp_year, 
                :card_last4, 
                :price_per_pound,
                :address_count,
                :address_street_address_0,
                :address_unit_number_0,
                :address_city_0,
                :address_state_0,
                :address_zipcode_0,
                :address_pick_up_directions_0,
                :address_phone_0,

                :address_street_address_1,
                :address_unit_number_1,
                :address_city_1,
                :address_state_1,
                :address_zipcode_1,
                :address_pick_up_directions_1,
                :address_phone_1,

                :address_street_address_2,
                :address_unit_number_2,
                :address_city_2,
                :address_state_2,
                :address_zipcode_2,
                :address_pick_up_directions_2,
                :address_phone_2,

                :address_street_address_3,
                :address_unit_number_3,
                :address_city_3,
                :address_state_3,
                :address_zipcode_3,
                :address_pick_up_directions_3,
                :address_phone_3,

                :address_street_address_4,
                :address_unit_number_4,
                :address_city_4,
                :address_state_4,
                :address_zipcode_4,
                :address_pick_up_directions_4,
                :address_phone_4,

                :address_street_address_5,
                :address_unit_number_5,
                :address_city_5,
                :address_state_5,
                :address_zipcode_5,
                :address_pick_up_directions_5,
                :address_phone_5,

                :address_street_address_6,
                :address_unit_number_6,
                :address_city_6,
                :address_state_6,
                :address_zipcode_6,
                :address_pick_up_directions_6,
                :address_phone_6,

                :address_street_address_7,
                :address_unit_number_7,
                :address_city_7,
                :address_state_7,
                :address_zipcode_7,
                :address_pick_up_directions_7,
                :address_phone_7,

                :address_street_address_8,
                :address_unit_number_8,
                :address_city_8,
                :address_state_8,
                :address_zipcode_8,
                :address_pick_up_directions_8,
                :address_phone_8,

                :address_street_address_9,
                :address_unit_number_9,
                :address_city_9,
                :address_state_9,
                :address_zipcode_9,
                :address_pick_up_directions_9,
                :address_phone_9,

  # extracted models
  :client

  # client
  validates :name, presence: true
  validates :phone, presence: true, length: { minimum: 10, maximum: 16 }
  validates :contact_person, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  validate :email_unique?
  validate :addresses_present?
  validate :pick_up_day_present?
  
  validates :area_of_business, presence: true
  validates :pickup_window, presence: true
  validates :card_brand, presence: true
  validates :card_exp_month, presence: true
  validates :card_exp_year, presence: true
  validates :card_last4, presence: true
  validates :price_per_pound, presence: true

  # address

  validates :address_street_address_0, presence: true, length: {
    maximum: 100
  }
  validates :address_unit_number_0, length: { maximum: 20}
  validates :address_city_0, presence: true, length: { maximum: 100}
  validates :address_state_0, presence: true, length: { maximum: 100}
  validates :address_zipcode_0, presence: true, length: { minimum: 5,   maximum: 5 }
  # validate :address_in_coverage_area?

  def save
    if valid?
      @client = Client.create!(
        name: name,
        phone: phone,
        email: email,
        special_notes: special_notes,
        contact_person: contact_person,
        area_of_business: area_of_business,
        monday: monday,
        tuesday: tuesday,
        wednesday: wednesday,
        thursday: thursday,
        friday: friday,
        saturday: saturday,
        sunday: sunday,
        pickup_window: pickup_window,
        card_brand: card_brand,
        card_exp_month: card_exp_month,
        card_exp_year: card_exp_year,
        card_last4: card_last4,
        price_per_pound: price_per_pound
      )

      address_count.to_i.times do |num|
        @address = @client.addresses.create!(
          street_address: self.send("address_street_address_#{num}"),
          unit_number: self.send("address_unit_number_#{num}"),
          city: self.send("address_city_#{num}"),
          state: self.send("address_state_#{num}"),
          zipcode: self.send("address_zipcode_#{num}"),
          phone: self.send("address_phone_#{num}"),
          pick_up_directions: self.send("address_pick_up_directions_#{num}")
        )

        @address.attempt_region_attach
      end
    end
  end

  def pick_up_day_present?
    if [monday,
      tuesday, 
      wednesday, 
      thursday,
      friday, 
      saturday, 
      sunday].all?{|day| day.to_i == 0}
      errors.add(:client, 'At least one pick up day is required.')
    end
  end

  def addresses_present?
    unless address_count.present? && address_count.to_i > 0
      errors.add(:address, 'At least 1 address is required.')
    end
  end

  def address_in_coverage_area?
    unless CoverageArea.find_by(zipcode: zipcode).present?
      errors.add(:address, 'Address not in service area')
    end
  end

  def email_unique?
    unless Client.where(email: email).none?
      errors.add(:email, 'has already been taken')
    end
  end

end