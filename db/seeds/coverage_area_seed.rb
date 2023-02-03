# frozen_string_literal: true

require 'csv'

coverage_areas_file = 'coverage_areas.csv'
coverage_areas_text = File.read(Rails.root.join('lib', 'seeds', coverage_areas_file))
coverage_areas = CSV.parse(coverage_areas_text.scrub, headers: true)
ca_row_count = coverage_areas.length
saved_ca_row_count = 0
coverage_areas.each do |row|
  t = CoverageArea.new
  t.zipcode = row['zipcode'].to_s
  t.state = row['state'].to_s
  t.county = row['county'].to_s
  t.city = row['city'].to_s
  if t.save
    puts "#{t.zipcode} saved."
    saved_ca_row_count += 1
  else
    puts "#{t.zipcode} was not saved."
  end
end
puts "From csv file '#{coverage_areas_file}': #{saved_ca_row_count} out of #{ca_row_count} rows were saved."
