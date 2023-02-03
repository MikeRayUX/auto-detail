# frozen_string_literal: true

# == Schema Information
#
# Table name: courier_problems
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint
#  worker_id           :bigint
#  occured_during_task :integer
#  occured_during_step :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address             :string
#  problem_encountered :integer
#

class CourierProblem < ApplicationRecord
  belongs_to :order
  belongs_to :worker

  validates :order_id, presence: true
  validates :worker_id, presence: true
  validates :occured_during_task, presence: true
  validates :occured_during_step, presence: true
  validates :problem_encountered, presence: true
  validates :address, length: {
    maximum: 100
  }
  
  enum problem_encountered: %i[
    no_residential_access
    business_closed
    cannot_locate_order
    customer_cancelled
  ]

  enum occured_during_task: %i[
    pickup_from_customer
    dropoff_to_partner
    pickup_from_partner
    deliver_to_customer
    checkout_holding_order
  ]

  enum occured_during_step: %i[
    step1
    step2
    step3
    step4
  ]

  def readable_attempted_at
    created_at.strftime('%m/%d/%Y at %I:%M%P')
  end

  def readable_problem
    case problem_encountered
    when 'no_residential_access'
      '"Unable to access building, or residential community."'
    when 'cannot_locate_order'
      '"Unable to locate customer order."'
    when 'business_closed'
      '"Business closed."'
    when 'customer_cancelled'
      '"Customer cancelled."'
    end
  end
end
