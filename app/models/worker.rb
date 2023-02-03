# frozen_string_literal: true

# == Schema Information
#
# Table name: workers
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  full_name              :string
#  phone                  :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  region_id              :bigint
#

class Worker < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :address
  has_many :orders
  has_many :courier_problems
  has_many :notifications
	belongs_to :region
	
  before_save :downcase_full_name

  devise :database_authenticatable,
				 :recoverable, :rememberable, :validatable

  validates :full_name, presence: true, length: { maximum: 75 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { minimum: 10, maximum: 10 }

  private

  def downcase_full_name
    self.full_name = full_name.downcase
  end
end
