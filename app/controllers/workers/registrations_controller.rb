# frozen_string_literal: true

class Workers::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   if verify_account_creation_code?
  #     # creates account
  #     super
  #   else
  #     # add flash message here
  #     flash[:notice] = "didn't work"
  #     redirect_to new_worker_registration_path
  #   end
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   added_attrs = %i(full_name phone email)
  #   devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
  # end

  # def worker_activation_code_params
  #   params.require(:worker_activation_code).permit(:code)
  # end

  # def verify_account_creation_code?
  #   return WorkerAccountCreationCode.where(code: worker_activation_code_params[:code]).exists?
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  #   faq_path
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
