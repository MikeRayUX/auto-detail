# frozen_string_literal: true

class Workers::RegistrationWithCodesController < ApplicationController
  layout 'static_pages/no_nav_layout'

  def new
    @worker = NewWorkerAccount.new
  end

  def create
    if activation_code_valid?
      @worker = NewWorkerAccount.new(worker_params)
      if @worker.save
        redirect_to new_worker_session_path, flash: { alert: 'Worker created successfully!' }
      else
        # redirect
        redirect_to new_workers_registration_with_code_path, flash: { alert: @worker.errors.full_messages.join(', ') }
      end
    else
      redirect_to new_workers_registration_with_code_path, flash: { alert: 'invalid activation code' }
    end
  end

  private

  def worker_params
    params.require(:new_worker_account).permit(:full_name, :email, :phone, :activation_code, :password, :password_confirmation, :street_address, :unit_number, :city, :state, :zipcode)
  end

  def activation_code_valid?
    WorkerAccountCreationCode.where(code: worker_params[:activation_code]).exists?
  end
end
