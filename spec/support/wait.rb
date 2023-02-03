# frozen_string_literal: true

module Wait
  def wait_1
    sleep 1.seconds
  end

  def wait_2
    sleep 2.seconds
  end

  def wait_3
    sleep 3.seconds
  end

  def wait_4
    sleep 4.seconds
  end

  def wait_5
    sleep 5.seconds
  end
  end

RSpec.configure do |config|
  config.include Wait, type: :feature
end
