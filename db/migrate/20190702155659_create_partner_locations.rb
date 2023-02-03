# frozen_string_literal: true

class CreatePartnerLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :partner_locations do |t|
      t.string :street_address
      t.string :zipcode
      t.string :state
      t.string :city
      t.string :unit_number
      t.string :region
      t.float :latitude
      t.float :longitude
      t.string :services_offered
      t.decimal :price_per_lb, precision: 12, scale: 2
      t.integer :turnaround_time_hours
      t.string :business_name
      t.string :business_phone
      t.string :business_email
      t.string :business_website
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :monday_hours
      t.string :tuesday_hours
      t.string :wednesday_hours
      t.string :thursday_hours
      t.string :friday_hours
      t.string :saturday_hours
      t.string :sunday_hours

      t.timestamps
    end
  end
end
