# frozen_string_literal: true

module Api::V1::Users::Dashboards::Orders::Schedulable
  extend ActiveSupport::Concern

  protected

  # def get_dates_for_select
  #   @dates_for_select = []
  #   7.times do |num|
  #     @dates_for_select.push(
  #       id: num,
  #       date: (Date.current + num).strftime('%d'),
  #       day: (Date.current + num).strftime('%a'),
  #       value: (Date.current + num).strftime,
  #       readable: (Date.current + num).strftime('%m/%d/%y')
  #     )
  #   end
  #   @dates_for_select[0][:day] = 'Today'
  #   @dates_for_select
  # end

  def requested_date_is_today?(requested)
    Date.parse(requested).today?
  end

  def requested_date_not_in_past?
    Date.parse(params[:pick_up_date]) >= Date.current
  end

  def remove_slots_in_past(possible_timeslots, available_slots)
    possible_timeslots.each do |slot|
      available_slots.delete(slot) if Time.parse(slot) <= 45.minutes.from_now
    end
  end

  def business_is_open?
    Date.parse(params[:pick_up_date]).strftime('%A') != 'Sunday'
    # true
  end

  def build_slots_for_select(slots)
    @slots_for_select = []
    slots.each do |slot|
      @slots_for_select.push(
        id: slots.index(slot),
        time: slot
      )
    end
    @slots_for_select
  end
end