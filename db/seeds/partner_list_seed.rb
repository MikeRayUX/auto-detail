# frozen_string_literal: true

require 'csv'
# partner list
partner_list_file = 'seattle_partner_list.csv'
partner_list_text = File.read(Rails.root.join('lib', 'seeds', partner_list_file))
partner_list = CSV.parse(partner_list_text.scrub, headers: true)
pl_row_count = partner_list.length
saved_pl_row_count = 0
partner_list.each do |row|
  t = PartnerLocation.new
  t.street_address = row['street_address'].to_s
  t.city = row['city'].to_s
  t.zipcode = row['zipcode'].to_s
  t.state = row['state'].to_s
  t.unit_number = row['unit_number'].to_s
  t.region = row['region'].to_s
  t.latitude = row['latitude'].to_f
  t.longitude = row['longitude'].to_f
  t.services_offered = row['services_offered'].to_s
  t.price_per_lb = row['price_per_lb'].to_f
  t.turnaround_time_hours = row['turnaround_time_hours'].to_i
  t.business_name = row['business_name'].to_s
  t.business_phone = row['business_phone'].to_s
  t.business_email = row['business_email'].to_s
  t.business_website = row['business_website'].to_s
  t.contact_name = row['contact_name'].to_s
  t.contact_phone = row['contact_phone'].to_s
  t.contact_email = row['contact_email'].to_s
  t.monday_hours = row['monday_hours'].to_s
  t.tuesday_hours = row['tuesday_hours'].to_s
  t.wednesday_hours = row['wednesday_hours'].to_s
  t.thursday_hours = row['thursday_hours'].to_s
  t.friday_hours = row['friday_hours'].to_s
  t.saturday_hours = row['saturday_hours'].to_s
  t.sunday_hours = row['sunday_hours'].to_s
  if t.save!
    puts "#{t.business_name} saved."
    saved_pl_row_count += 1
  else
    puts "#{t.business_name} was not saved."
  end
end
puts "From csv file '#{partner_list_file}': #{saved_pl_row_count} out of #{pl_row_count} rows were saved."
