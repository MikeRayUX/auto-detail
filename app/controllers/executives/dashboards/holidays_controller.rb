# frozen_string_literal: true

class Executives::Dashboards::HolidaysController < ApplicationController
  before_action :authenticate_executive!
  
  layout 'executives/dashboards/holidays/datepicker_layout'

  # executives_dashboards_holidays_path
  def index
    @upcoming = Holiday.all.upcoming.order(date: :asc)
  end

  # new_executives_dashboards_holiday_path
  def new

  end

  # executives_dashboards_holidays_path
  def create
    @holiday = Holiday.new(holiday_params)

    if @holiday.valid? && @holiday.not_already_taken?
      @holiday.save
      redirect_to executives_dashboards_holidays_path, flash: {
        notice: 'Holiday Added Successfully'
      }
    else
      flash[:notice] = "Date has already been taken."
      render :new
    end
  end

  # executives_dashboards_holiday_path
  def destroy
    @holiday = Holiday.find(params[:id])

    if @holiday
      @holiday.destroy

      redirect_to executives_dashboards_holidays_path,flash: {
        notice: 'Holiday Delted.'
      }
    else 
      redirect_to executives_dashboards_holidays_path,flash: {
        notice: 'Holiday could not be deleted.'
      }
    end
  end

  private
  def holiday_params
    params.require(:holiday).permit(%i[
      title
      date
    ])
  end
end