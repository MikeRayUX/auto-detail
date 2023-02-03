# == Schema Information
#
# Table name: notifications
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint
#  user_id             :bigint
#  notification_method :integer
#  event               :integer
#  sent                :boolean
#  sent_at             :datetime
#  send_errors         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  message_body        :string
#  worker_id           :integer
#  new_order_id        :bigint
#

class Notification < ApplicationRecord
	scope :enroute_for_pickup, -> { where(event: 'enroute_to_customer_for_pickup') }
	scope :arrived, -> { where(event: 'arrival_for_pickup')}
	scope :picked_up, -> { where(event: 'order_picked_up')}
  scope :delivered, -> { where(event: 'order_delivered')}
  scope :pickup_rejected, -> { where(event: 'pickup_rejected')}

  belongs_to :user, optional: true
  belongs_to :order, optional: true
  belongs_to :new_order, optional: true
  belongs_to :worker, optional: true

  validates :notification_method, presence: true
  validates :event, presence: true
  validates :sent_at, presence: true
  validates :message_body, presence: true, length: {
    maximum: 500
  }

  enum notification_method: %i[
    sms
    email
  ] 

  enum event: %i[
    enroute_to_customer_for_pickup
    arrival_for_pickup
		order_picked_up
    order_delivered
    pickup_rejected
    order_cancelled
    new_inquiry
    new_support_ticket
    new_order
  ]
end
