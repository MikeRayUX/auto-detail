# frozen_string_literal: true

class NewWorkerAccount
  include ActiveModel::Model

  attr_accessor :full_name, :email, :phone, :password, :password_confirmation, :activation_code, :street_address, :unit_number, :city, :state, :zipcode,
                # extracted @user @order @address @appointment for access in the controller @NewCustomerOrder.user @.order @.address
                :worker, :address

  # worker
  validates :full_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { maximum: 75 }
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validate :worker_email_unique

  # Address
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zipcode, presence: true

  def save
    if valid?
      @worker = Worker.create!(full_name: full_name, email: email, phone: phone, password: password, password_confirmation: password_confirmation)
      @address = Address.create!(worker_id: @worker.id, street_address: street_address, unit_number: unit_number, city: city, state: state, zipcode: zipcode)

    end
  end

  def worker_email_unique
    unless Worker.where(email: email).none?
      errors.add(:email, 'has already been taken')
    end
  end
end
