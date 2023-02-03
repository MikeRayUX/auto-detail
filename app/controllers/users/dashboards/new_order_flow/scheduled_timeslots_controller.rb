class Users::Dashboards::NewOrderFlow::ScheduledTimeslotsController < ApplicationController
  MAX_FUTURE_DAYS = 5

  # open timeslots/dates
  # users_dashboards_new_order_flow_scheduled_timeslots_path
  # /users/dashboards/new_order_flow/scheduled_timeslots
  def index
    @dates_for_select = []
      MAX_FUTURE_DAYS.times do |num|
        @date = Date.current + (num + 1)
        @dates_for_select.push(
          id: num,
          date: @date.strftime('%d'),
          day: @date.strftime('%a').upcase,
          value: @date.strftime,
          readable: @date.strftime('%m/%d/%y'),
          holiday: Holiday.is_holiday?(@date.strftime),
          timeslots: Appointment::HOURLY_TIMESLOTS
        )
      end
 
      render json: {
        code: 200,
        message: 'dates_returned',
        dates_for_select: @dates_for_select
      }
  end
end