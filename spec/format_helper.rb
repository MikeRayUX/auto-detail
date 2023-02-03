# frozen_string_literal: true

module Formattable
  extend ActiveSupport::Concern

  def readable_decimal(attribute)
    "#{format('%.2f', attribute)}"
  end

  def truncate_attribute(attribute, max)
    if attribute.length > max
      "#{attribute[0...max]}..."
    else
      attribute
    end
  end

  def readable_decimal(decimal)
    "#{format('%.2f', decimal)}"
  end

  def readable_percent(float)
    (float * 100).round(2)
  end

  def readable_date(date)
    date.strftime('%m/%d/%Y')
  end

  def readable_date(date)
    date.strftime('%m/%d/%Y')
  end

  def readable_date_with_time(date)
    date.strftime('%m/%d/%Y at %I:%M%P')
  end

  def readable_delivery(date)
    date.strftime('%m/%d/%Y by %I:%M%P')
  end
  
end
