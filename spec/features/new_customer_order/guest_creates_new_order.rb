# frozen_string_literal: true

# require 'rails_helper'

# RSpec.feature "Guest user creates a new order", truncation: true do

#   before(:each) do
#     region = create(:region_pricing)
#     area = create(:coverage_area)
#     @pick_up_time = "6:30AM"
#   end

#   todays_date = Date.current.strftime("%m/%d/%Y")
#   tomorrows_date = Date.current.tomorrow.strftime("%m/%d/%Y")

#   # account info
#   password = "password"
#   password_confirmation = "password"
#   phone = "1234567890"

#   # cardinfo
#   card_number = "42424242424242424242424242"
#   card_exp = "0424"
#   card_cvc = "242"
#   # invalid_card_number = "42424242"

#   # address info
#   street_address = "14300 1st ave s"
#   unit_number = "12B"
#   city = "Burien"
#   valid_zipcode = "98168"
#   not_covered_zip = "55555"

#   scenario "order is valid" do

#     # check areacode
#     visit root_path
#     click_on "Book Now"
#     step_1 = find('fieldset:first-of-type')

#     within step_1 do
#       fill_in "zipcode", with: valid_zipcode
#       click_on "Check"
#     end

#     # step 1 start order
#     step_2 = find('fieldset:first-of-type')

#     within step_2 do

#       if Time.current < Time.parse("8:00PM")
#         fill_in "Pick up date", with: todays_date
#       else
#         fill_in "Pick up date", with: tomorrows_date
#       end

#       wait_for_ajax

#       fill_in "new_customer_order[pick_up_directions]", with: Faker::Quotes::Shakespeare.hamlet_quote
#       fill_in "new_customer_order[special_notes]", with: Faker::Quotes::Shakespeare.hamlet_quote

#       first('#new_customer_order_pick_up_time option').select_option

#       # select @pick_up_time, from: "new_customer_order[pick_up_time]"

#       click_on "next"
#     end

#     wait_1

#     # step 2 create account
#     step_3 = find('fieldset:nth-of-type(2)')

#     within step_3 do
#       fill_in "new_customer_order[street_address]", with: street_address
#       fill_in "new_customer_order[unit_number]", with: unit_number
#       fill_in "new_customer_order[city]", with: city
#       select "Washington", from: "new_customer_order[state]"
#       fill_in "new_customer_order[zipcode]", with: valid_zipcode

#       click_on "next"
#     end

#     wait_1

#     # step 3 address info
#     step_3 = find('fieldset:nth-of-type(3)')
#     within step_3 do
#       fill_in "new_customer_order[full_name]", with: Faker::Name.name
#       fill_in "new_customer_order[email]", with: Faker::Internet.email
#       fill_in "new_customer_order[phone]", with: phone
#       fill_in "new_customer_order[phone]", with: phone
#       fill_in "new_customer_order[password]", with: password
#       fill_in "new_customer_order[password_confirmation]", with: password_confirmation

#       click_on "next"
#     end

#     wait_1
#     wait_for_ajax

#     # step 4 payment info
#     step_4 = find('fieldset:nth-of-type(4)')

#     within step_4 do
#       card_element = find('#card-element > div > iframe')
#       within_frame card_element do
#         fill_in'cardnumber', with: "4242424242424242424242424242424242"
#       end

#       click_on "Pay $25.00"
#     end

#     wait_for_ajax

#     wait_5

#     @order = Order.first
#     @appointment = @order.appointment
#     @transaction = @order.transactions.find_by(transaction_type: "deposit")
#     @user = @order.user
#     @address = @user.address
#     # p "***** ORDER:"
#     # p @order
#     # p "***** APPOINTMENT:"
#     # p @appointment
#     # p "***** TRANSACTION: "
#     # p @transaction
#     # p "***** Number of orders: #{Order.all.count}"
#     # p "***** USER: "
#     # p @user

#     # p "@order.reference code: #{@order.reference_code}"
#     # p "@transaction.order_reference_code: #{@transaction.order_reference_code}"

#     expect(@transaction.order_reference_code).to eq(@order.reference_code)
#     expect(@order.pick_up_date).to eq(@appointment.pick_up_date)
#     expect(@transaction.transaction_type).to eq("deposit")
#     expect(@transaction.grandtotal).to eq("25.00".to_f)
#     expect(@address.latitude).to be_truthy
#     expect(@address.longitude).to be_truthy
#     expect(page).to have_content("Thank you for your order!")
#     expect(page).to have_content(@order.reference_code)

#   end

#   scenario "user tries to create account with address that isn't in coverage area" do

#     # check areacode
#     visit root_path
#     click_on "Book Now"
#     step_1 = find('fieldset:first-of-type')

#     within step_1 do
#       fill_in "zipcode", with: valid_zipcode
#       click_on "Check"
#     end

#     # # step 1 start order
#     step_2 = find('fieldset:first-of-type')

#     within step_2 do
#       if Time.current < Time.parse("8:00PM")
#         fill_in "Pick up date", with: todays_date
#       else
#         fill_in "Pick up date", with: tomorrows_date
#       end

#       wait_for_ajax

#       fill_in "new_customer_order[pick_up_directions]", with: Faker::Quotes::Shakespeare.hamlet_quote
#       fill_in "new_customer_order[special_notes]", with: Faker::Quotes::Shakespeare.hamlet_quote

#       first('#new_customer_order_pick_up_time option').select_option

#       click_on "next"
#     end

#     wait_1

#     # step 3 address info
#     step_3 = find('fieldset:nth-of-type(2)')
#     within step_3 do
#       fill_in "new_customer_order[street_address]", with: street_address
#       fill_in "new_customer_order[unit_number]", with: unit_number
#       fill_in "new_customer_order[city]", with: city
#       select "Washington", from: "new_customer_order[state]"
#       fill_in "new_customer_order[zipcode]", with: not_covered_zip

#       click_on "next"
#     end

#     wait_1

#     # step 2 create account
#     step_4 = find('fieldset:nth-of-type(3)')

#     within step_4 do
#       fill_in "new_customer_order[full_name]", with: Faker::Name.name
#       fill_in "new_customer_order[email]", with: Faker::Internet.email
#       fill_in "new_customer_order[phone]", with: phone
#       fill_in "new_customer_order[phone]", with: phone
#       fill_in "new_customer_order[password]", with: password
#       fill_in "new_customer_order[password_confirmation]", with: password_confirmation

#       click_on "next"
#     end

#     wait_1
#     wait_for_ajax

#     # step 4 payment info
#     step_4 = find('fieldset:nth-of-type(4)')

#     within step_4 do
#       card_element = find('#card-element > div > iframe')
#       within_frame card_element do
#         fill_in'cardnumber', with: "4242424242424242424242424242424242"
#       end

#       click_on "Pay $25.00"
#     end
#     wait_for_ajax

#     expect(page).to have_content("Aww man! It looks like we aren't available in your area yet!")
#   end

# end
