# frozen_string_literal: true

# == Schema Information
#
# Table name: appointments
#
#  id           :bigint           not null, primary key
#  order_id     :bigint
#  pick_up_date :datetime
#  pick_up_time :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Appointment < ApplicationRecord
  belongs_to :order, optional: true

  validates :pick_up_date, presence: true, uniqueness: { scope: :pick_up_time }
	validates :pick_up_time, presence: true
	
	POSSIBLE_TIMESLOTS = %w[9:00AM 9:30AM 10:00AM 10:30AM 11:00AM 11:30AM 12:00PM 12:30PM 1:00PM 1:30PM 2:00PM 2:30PM 3:00PM 3:30PM 4:00PM 4:30PM 5:00PM 5:30PM 6:00PM 6:30PM 7:00PM 7:30PM 8:00PM]

	HOURLY_TIMESLOTS = %w[
		9:00AM 
		1:00PM 
		5:00PM 
		10:00AM 
		2:00PM 
		6:00PM 
		11:00AM 
		3:00PM 
		7:00PM 
		12:00PM 
		4:00PM 
		8:00PM
	]

	def is_approaching?
		@time = Time.parse(pick_up_time)
		@time.future? && @time <= 1.hour.from_now
	end

  private
end
