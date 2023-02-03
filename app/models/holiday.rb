# == Schema Information
#
# Table name: holidays
#
#  id         :bigint           not null, primary key
#  title      :string
#  date       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Holiday < ApplicationRecord
  scope :upcoming, -> {where("date >= ?", DateTime.current)}
  scope :paste, -> { where("date < ?", DateTime.current.all_day) }

  validates :title, presence: true
  validates :date, presence: true

  def self.is_holiday?(date)
    Holiday.find_by(date: date).present?
  end

  def not_already_taken?
    Holiday.find_by(date: self.date).blank?
  end
end
