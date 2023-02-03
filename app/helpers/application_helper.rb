# frozen_string_literal: true

require 'active_support/all'

module ApplicationHelper
  module Helpers
    extend ActiveSupport::NumberHelper
  end

  def today_from_string?(day)
    Date.parse(day).today?
  end

  def states_for_select
    ["Alaska",
      "Alabama",
      "Arkansas",
      "American Samoa",
      "Arizona",
      "California",
      "Colorado",
      "Connecticut",
      "District of Columbia",
      "Delaware",
      "Florida",
      "Georgia",
      "Guam",
      "Hawaii",
      "Iowa",
      "Idaho",
      "Illinois",
      "Indiana",
      "Kansas",
      "Kentucky",
      "Louisiana",
      "Massachusetts",
      "Maryland",
      "Maine",
      "Michigan",
      "Minnesota",
      "Missouri",
      "Mississippi",
      "Montana",
      "North Carolina",
      " North Dakota",
      "Nebraska",
      "New Hampshire",
      "New Jersey",
      "New Mexico",
      "Nevada",
      "New York",
      "Ohio",
      "Oklahoma",
      "Oregon",
      "Pennsylvania",
      "Puerto Rico",
      "Rhode Island",
      "South Carolina",
      "South Dakota",
      "Tennessee",
      "Texas",
      "Utah",
      "Virginia",
      "Virgin Islands",
      "Vermont",
      "Washington",
      "Wisconsin",
      "West Virginia",
      "Wyoming"]
  end

  # user navbar active link
  def current_class?(path)
    if request.path == path
      "block m-auto text-right py-4 pr-5 border-b border-gray-300 text-white md:pl-64 bg-primary text-white"
    else
      "block m-auto text-right py-4 pr-5 border-b border-gray-300 text-white md:pl-64"
    end
  end

  def highlighted_sort?(path)
    if request.url == path
      'text-xs font-bold bg-gray-800 text-gray-300 py-1 px-2 focus:outline-none'
    else
      'text-xs font-bold bg-white text-gray-900 py-1 px-2 focus:outline-none border-r'
    end
  end 

  def truncate_attribute(attribute, max)
    if attribute.length > max
      "#{attribute[0...max]}..."
    else
      attribute
    end
  end

  def linify_string(body)
    body.split("\n")
  end

  def readable_decimal(decimal)
    "#{format('%.2f', decimal)}"
  end

  def readable_percent(float)
    (float * 100).round(2)
  end

  def readable_date_from_string(date)
    Date.parse(date).strftime('%m/%d/%Y')
  end

  def current_age_from_string(date_string)
    # converts mm/dd/yyyy to yyyy-mm-dd
    split = date_string.split('/')
    date = Date.parse("#{split[2]}-#{split[0]}-#{split[1]}")
    ((Time.current - date.to_time) / 1.year.seconds).floor
  end

  def current_age(date)
    ((Time.current - date.to_time) / 1.year.seconds).floor
  end

  def readable_date(date)
    date.strftime('%m/%d/%Y')
  end

  def readable_date_with_time(date)
    date.strftime('%m/%d/%Y at %I:%M%P')
  end

  # worker navbar active link
  def current_worker_class?(path)
    if request.path == path
      "block m-auto text-right py-4 pr-5 md:pl-64 bg-black"
    else
      "block m-auto text-right py-4 pr-5 md:pl-64 bg-orange-600"
    end
  end

  # executive navbar active link
  def executive_highlight?(path)
    if request.path == path
      "text-gray-300 text-right pr-4 font-bold leading-snug block mb-1 text-xs bg-gray-900 rounded-md"
    else
      "text-gray-400 text-right pr-4 leading-snug block font-bold mb-1 text-xs"
    end
  end

  def executive_highlight_with_params?(url)
    if request.url == url
      "text-gray-300 text-right pr-4 font-bold leading-snug block mb-1 text-xs bg-gray-900 rounded-md"
    else
      "text-gray-400 text-right pr-4 leading-snug block font-bold mb-1 text-xs"
    end
  end

  def today
    Date.current.strftime('%m/%d/%y')
  end

  def mtd
    "#{Date.current.at_beginning_of_month.strftime('%m/%d/%y')} - #{Date.current.strftime('%m/%d/%y')}"
  end

  def ytd
    "#{Date.current.at_beginning_of_year.strftime('%m/%d/%y')} - #{Date.current.strftime('%m/%d/%y')}"
  end
end