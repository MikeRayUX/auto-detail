require 'rails_helper'

RSpec.describe 'api/v1/users/dashboards/account_settings/update_phone_numbers_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    @auth_token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user is not logged in' do
    put '/api/v1/users/dashboards/account_settings/update_phones', 
      params: {
        phone: {
          phone: '123123'
        }
      },
      headers: {
        Authorization: ''
      }

      json = JSON.parse(response.body).with_indifferent_access

      # response
      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user updates their phone number with a valid number' do
    area_code = '562'
    first_three = '787'
    last_4 = '2684'

    variations = [
      "#{area_code}#{first_three}#{last_4}",
      "(#{area_code})#{first_three}-#{last_4}",
      "+1(#{area_code})#{first_three}-#{last_4}",
      "+1#{area_code}#{first_three}#{last_4}",
      "+1#{area_code}#{first_three}-#{last_4}",
    ]

    expected = "#{area_code}#{first_three}#{last_4}"

    variations.count.times do |num|
      put '/api/v1/users/dashboards/account_settings/update_phones', 
      params: {
        user: {
          phone: variations[num]
        }
      },
      headers: {
        Authorization: @auth_token
      }

      @user.reload

      p "submitted phone: #{variations[num]}, sanitized phone: #{@user.phone}"

      json = JSON.parse(response.body).with_indifferent_access

      # response
      expect(json[:code]).to eq 204
      expect(json[:message]).to eq 'phone_updated_successfully'
      expect(json[:feedback]).to eq 'Phone updated successfully!'
      # current_user
      expect(json[:current_user]).to be_present
      expect(json[:current_user][:full_name]).to eq @user.full_name.titleize
      expect(json[:current_user][:first_name]).to eq @user.first_name
      expect(json[:current_user][:email]).to eq @user.email
      expect(json[:current_user][:phone]).to eq @user.formatted_phone
    end
  end
end