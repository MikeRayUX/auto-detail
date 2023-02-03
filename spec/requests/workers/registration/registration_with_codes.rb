# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registration with codes controller', type: :request do

	before do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end


	after do
		ActionMailer::Base.deliveries.clear
		DatabaseCleaner.clean_with(:truncation)
	end


	# scenario 'worker can view the account creation page' do
	# 	get new_workers_registration_with_code_path

	# 	@page = response.body

	# end

	# scenario 'worker can create an account' do
	# 	post workers_registration_with_codes_path, params: {
	# 		new_worker_account: {
	# 			email: 'something@sample.com',
	# 			full_name: 'John Doe',
	# 			phone: '3216549879',
	# 			password: 'password',
	# 			password_confirmation: 'password',
	# 			street_address: '123 sample street',
	# 			unit_number: '54',
	# 			city: 'seattle',
	# 			state: 'washington',
	# 			zipcode: '99999',
	# 			activation_code: @activation_code.code
	# 		}
	# 	}

	# 	expect(response).to redirect_to new_worker_session_path
	# 	expect(Worker.count).to eq 1
	# end

	# scenario 'worker is kicked back with invalid form errors' do
	# 	post workers_registration_with_codes_path, params: {
	# 		new_worker_account: {
	# 			email: 'something@sample.com',
	# 			phone: '3216549879',
	# 			password: 'password',
	# 			password_confirmation: 'password',
	# 			street_address: '123 sample street',
	# 			unit_number: '54',
	# 			city: 'seattle',
	# 			state: 'washington',
	# 			zipcode: '99999',
	# 			activation_code: '123456'
	# 		}
	# 	}
	# 	expect(response).to redirect_to new_workers_registration_with_code_path
	# end
 
end
