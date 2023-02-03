# == Schema Information
#
# Table name: work_sessions
#
#  id                 :bigint           not null, primary key
#  washer_id          :bigint
#  last_checked_in_at :datetime
#  terminated_at      :datetime
#  secure_id          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class WorkSession < ApplicationRecord
  # 10 minutes
  REFRESH_LIMIT = 10

  scope :refreshable, -> {where("last_checked_in_at > ?", REFRESH_LIMIT.minutes.ago).where(terminated_at: nil)}
  scope :stale, -> {where("last_checked_in_at < ?", REFRESH_LIMIT.minutes.ago).where(terminated_at: nil)}
  scope :terminated, -> {where.not(terminated_at: nil)}

  belongs_to :washer
  validates :secure_id, presence: true
  
  def stale?
    last_checked_in_at < REFRESH_LIMIT.minutes.ago
  end

  def refreshable?
    last_checked_in_at > REFRESH_LIMIT.minutes.ago && !terminated_at
  end

  def refresh!
    update(last_checked_in_at: DateTime.current)
  end

  def terminatable?
    terminated_at.blank?
  end

  def terminated?
    terminated_at.present?
  end

  def terminate!
    update(terminated_at: DateTime.current)
  end
  
  def duration
    if terminated_at
      "#{((terminated_at.to_time - created_at.to_time ) / 1.hours).round(2)} hours"
    else
      "not terminated"
    end
  end

end
