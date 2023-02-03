require 'rails_helper'

RSpec.describe 'user_dashbaords_settings_info_summaries_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user views update phone numebr page' do
    get users_dashboards_settings_update_phones_path

    page = response.body

    expect(page).to include('Enter Your New Phone Number')
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
      put users_dashboards_settings_update_phones_path, params: {
        phone: {
          phone: variations[num]
        }
      }

      @user.reload

      p "submitted phone: #{variations[num]}, sanitized phone: #{@user.phone}"
      
      expect(@user.phone).to eq expected
    end
  end
end