# == Schema Information
#
# Table name: support_tickets
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint
#  subject              :string
#  body                 :string
#  order_reference_code :string
#  customer_name        :string
#  customer_email       :string
#  customer_phone       :string
#  pick_up_appointment  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  concern              :integer
#  closed_at            :datetime
#  last_viewed          :datetime
#  washer_id            :bigint
#

class SupportTicket < ApplicationRecord
  scope :open, -> { where(closed_at: nil)}
  scope :closed, -> { where.not(closed_at: nil)}
  scope :viewed, -> {where(last_viewed: nil)}
  scope :unread, -> {where.not(last_viewed: nil)}

  before_destroy :delete_replies

  belongs_to :order, optional: true
  belongs_to :user, optional: true
  belongs_to :washer, optional: true
  has_many :support_ticket_replies

  validates :customer_email, presence: true,format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :subject, presence: true, length: { maximum: 50}
  validates :body, presence: true, length: { maximum: 1000 }
  validates :concern, presence: true

  enum concern: %i[
    order_related
    general_inquiry
    bug_report
    washer_support
    customer_app
  ]

  def replies
    support_ticket_replies
  end

  def unread?
    last_viewed == nil
  end

  def viewed?
    last_viewed != nil
  end

  def open?
    closed_at == nil
  end

  def closed?
    closed_at.present?
  end

  def mark_closed!
    update_attribute(:closed_at, DateTime.current)
  end

  def mark_opened!
    update_attribute(:closed_at, nil)
  end

  def mark_viewed
    update_attribute(:last_viewed, DateTime.current)
  end

  def mark_unread
    update_attribute(:last_viewed, nil)
  end

  def readable_concern
    case concern
    when 'order_related'
      "Order #{order_reference_code}"
    when 'general_inquiry'
      'General Inquiry'
    when 'bug_report'
      'Bug Report'
    when 'washer_support'
      'Washer Support'
    when 'customer_app'
      'Customer App'
    end
  end

  def readable_created_at
    created_at.strftime('%m/%d/%Y')
  end

  def created_with_time
    created_at.strftime('%m/%d/%Y at %I:%M%P')
  end

  private
  # debug
  def self.create_sample_tickets!
    10.times do
      SupportTicket.create!(
        FactoryBot.attributes_for(:support_ticket)
        .merge(
          concern: 'general_inquiry',
          body: Faker::GreekPhilosophers.quote
        )
      )
    end
  end

  def delete_replies
    if replies.any?
      replies.destroy_all
    end
  end

end
