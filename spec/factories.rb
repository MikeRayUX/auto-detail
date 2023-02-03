# frozen_string_literal: true
require 'faker'

FactoryBot.define do
  factory :holiday do
    title "MyString"
    date "2021-05-22 16:54:37"
  end
  factory :email_send do
    
  end

  factory :sendgrid_email do
    template_id "d-296d25bbc37d4088aaa1c5b154f419f8"
    description "Test Marketing"
    category 'customer_promotion'
    preview_url 'asdkjfaslkdjflkj'
    content_summary 'this is a test email'

    trait :invalid_template_id do
      template_id "oiejfoijasdjf"
    end
  end

  factory :offer_action do
    
  end
  
  factory :subscription do
    name 'Tumble Subscription'
    # stripe->products
    stripe_product_id 'prod_IlwZ2R7eYeCrIj'
    stripe_price_id 'price_1IAOfwIhRzEonUQKOm1pEOt3'
    price 9.99
  end
  
  factory :work_session do
    secure_id SecureRandom.hex(3)

    trait :refreshable do
      last_checked_in_at {DateTime.current - (rand(1..WorkSession::REFRESH_LIMIT - 1).minutes)}
    end

    trait :stale do
      last_checked_in_at{DateTime.current - (WorkSession::REFRESH_LIMIT + 1).minutes}
    end

    trait :terminated do
      last_checked_in_at{ DateTime.current - rand(11..100).minutes}
      terminated_at DateTime.current
    end
  end

  factory :new_order do
    # ref_code MUST MERGE OTHERWISE MULTIPLE CREATES WILL HAVE ALL HAVE THE SAME REF_CODE
    # user_id MUST MERGE
    # washer_id MUST MERGE
    # region_id MUST MERGE
    # subtotal MUST MERGE
    # tax MUST MERGE
    # tax_rate MUST MERGE
    # grandtotal MUST MERGE
    # tip MUST MERGE
    # address MUST MERGE
    # unit_number MUST MERGE
    # directions MUST MERGE
    # tax_rate MUST MERGE
    # bag_price MUST MERGE FROM REGION     
    # profit MUST MERGE
    detergent {NewOrder.detergents.keys.sample}
    softener {NewOrder.softeners.keys.sample}
    bag_count {rand(1..4)}
    est_delivery {DateTime.current + 24.hours}
    stripe_charge_id 'asdfasdfasdf'

    trait :open_offer do
      accept_by {DateTime.current + NewOrder::ACCEPT_LIMIT}
    end

    trait :expired do
      accept_by {DateTime.current + 1.minutes}
    end

    trait :accepted do
      accepted_at {DateTime.current}
    end

    trait :scheduled do
      scheduled {rand(1..3).days.from_now}
    end

    trait :in_progress do
      accepted_at {DateTime.current}
      picked_up_at {DateTime.current + 1.hours}
    end

    trait :ready_for_delivery do
      accepted_at {DateTime.current + 1.hours}
      picked_up_at {DateTime.current + 2.hours}
      completed_at {DateTime.current + 12.hours}
    end

    trait :delivered do
      accepted_at {DateTime.current }
      picked_up_at  {DateTime.current + 1.hours}
      completed_at {DateTime.current + 12.hours}
      delivered_at {DateTime.current + 12.hours}
      delivery_location 'Back door'
    end

    trait :cancelled do
      cancelled_at {DateTime.current}
    end
  end

  factory :washer_application_question do
  end
  
  factory :washer do
    full_name Faker::Name.first_name
    email 'arriaga562@gmail.com'
    password 'password'
    password_confirmation 'password'
    phone '4055555555'
    authenticate_with_otp false
    
      trait :applied do
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        #stripe_account_id (must create stripe account)
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        tax_agreement_accepted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
      end

      trait :activated do
        # application_completed? attributes
        full_name {"#{Faker::Name.first_name} #{Faker::Name.last_name}"}
        email 'arriaga562@gmail.com'
        phone '4055555555'
        live_within_region true
        min_age true
        legal_to_work true
        valid_drivers_license true
        valid_car_insurance_coverage true
        reliable_transportation true
        valid_ssn true
        has_equipment true
        can_lift_30_lbs true
        has_disability false
        consent_to_background_check true
        # activation steps attributes 
        app_invitation_sent_at DateTime.current
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        drivers_license "asdfjlasdlkfj"
        # region_id MUST MERGE
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'asdfasdasfdasdf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
      end

      trait :activated_as_employee do
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        stripe_account_id 'sadfsadf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        payoutable_as_ic false
        authenticate_with_otp false
      end

      trait :payoutable do
        # in order for this factory to work properly, you must go through the stripe connect express wizard and activate a test account in order to have transfers enabled. Then go to the stripe dashboard, grab an activated connect id, and update the washer's stripe_account_id and use that id to run this spec, otherwise the transfer will throw an error and fail
        # region_id MUST MERGE
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'acct_1IAPLmRH6sctP79Q'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        background_check_approved_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        authenticate_with_otp false

      end


      trait :deactivated do
        # region_id MUST MERGE
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'asdfasdasfdasdf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        deactivated_at DateTime.current
        authenticate_with_otp false
      end

      trait :online do
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'asdfasdasfdasdf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        last_online_at DateTime.current
      end

      trait :online do
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'asdfasdasfdasdf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        last_online_at DateTime.current
      end

      trait :offline do
        first_name Faker::Name.first_name
        middle_name Faker::Name.middle_name
        last_name Faker::Name.last_name
        ssn {"#{rand(101..999)}-#{rand(11..99)}-#{rand(1001..9999)}"}
        date_of_birth Faker::Date.birthday(min_age: 21, max_age: 65).strftime('%Y-%m-%d')
        phone '4055555555'
        drivers_license "asdfjlasdlkfj"
        # requires region_id to be available for orders
        # stripe_account_id {
        #   Stripe::Account.create({
        #     type: 'express',
        #     country: 'US',
        #     email: self.email,
        #     capabilities: {
        #       transfers: {requested: true},
        #       tax_reporting_us_1099_misc: {requested: true}
        #     }
        #   }).id
        # }
        stripe_account_id 'asdfasdasfdasdf'
        completed_app_intro_at DateTime.current 
        tos_accepted_at DateTime.current
        eligibility_completed_at DateTime.current
        background_check_submitted_at DateTime.current
        insurance_agreement_accepted_at DateTime.current 
        tax_agreement_accepted_at DateTime.current
        activated_at DateTime.current
        last_online_at {DateTime.current - (WorkSession::REFRESH_LIMIT + 1).minutes }
      end
  end
  
  factory :support_ticket_reply do
    
  end

  factory :wait_list do
    zipcode '98168'
    email Faker::Internet.email
  end

  factory :commercial_pickup do
    
  end
  
  factory :site_banner do
    
  end

  factory :region do
		area 'seattle wa'
    tax_rate 0.101
    price_per_bag 25
    # https://dashboard.stripe.com/tax-rates
    # in stripe dashboard :stripe->products->tax_rates
    stripe_tax_rate_id 'txr_1IAOYwIhRzEonUQKFpEY5pAK'
    max_concurrent_offers 5
    failed_pickup_fee 5
    washer_pay_percentage 0.8
    business_open "9:00AM"
    business_close "8:00PM"

      trait :open_washer_capacity do
        washer_capacity 100
      end

      trait :no_washer_capacity do
        washer_capacity 0
      end
  end
  
  factory :notification do
    
  end
  
  factory :inquiry do
    email Faker::Internet.email
    body  Faker::GreekPhilosophers.quote
  end
  
  factory :jwt_blacklist do
    
  end
  
  factory :coverage_area do
    zipcode '98168'
    state 'washington'
    county 'king'
    city 'seattle'

    trait :invalid do
      zipcode nil
    end
  end

  factory :region_pricing do
    region 'seattle'
    price_per_pound '1.99'.to_d
    tax_rate '.101'.to_d
    minimum_charge 25
	end

  factory :partner_location do
    street_address '1829 s 120th st'
    zipcode '98168'
    state 'wa'
    city 'seattle'
    unit_number ''
    region 'seattle'
    latitude 47.495538
    longitude -122.308984
    services_offered ''
    price_per_lb 0.0
    turnaround_time_hours 0
    business_name 'Boulevar Park Coin Laundry'
    business_phone '2062462238'
    business_email 'coinlaundries3@gmail.com'
    business_website ''
    contact_name ''
    contact_phone ''
    contact_email ''
    monday_hours '7am-10pm'
    tuesday_hours '7am-10pm'
    wednesday_hours '7am-10pm'
    thursday_hours '7am-10pm'
    friday_hours '7am-10pm'
    saturday_hours '7am-10pm'
    sunday_hours '7am-10pm'
  end

  factory :user do
    email 'arriaga562@gmail.com'
    full_name 'John Doe'
    # card_brand "VISA" MUST MERGE
    # card_exp_month "05" MUST MERGE
    # card_exp_year "2020" MUST MERGE
    # card_last4 "4242" MUST MERGE
    # CLICKSEND TEST PHONE NUMBER (doesn't incure charges)
    phone '4055555555'
    # phone '5627872684'
    password 'password'
    password_confirmation 'password'
    
    trait :invalid_email do
      email 'as;ldkfjas'
		end
		
		trait :with_payment_method do
			card_brand 'visa'
      card_exp_month '04'
      card_exp_year '24'
      card_last4 '4242'
		end

		trait :with_invalid_stripe do
			stripe_customer_id 'aoskjdfoasjfd'
			card_brand 'visa'
      card_exp_month '04'
      card_exp_year '24'
      card_last4 '4242'
    end
    
    trait :with_active_subscription do
			stripe_customer_id 'aoskjdfoasjfd'
			card_brand 'visa'
      card_exp_month '04'
      card_exp_year '24'
      card_last4 '4242'
      stripe_subscription_id 'asdfasdfasdf'
      subscription_activated_at DateTime.current
      subscription_expires_at {DateTime.current + 1.month}
    end
    
    trait :never_subscribed do
			stripe_customer_id 'aoskjdfoasjfd'
			card_brand 'visa'
      card_exp_month '04'
      card_exp_year '24'
      card_last4 '4242'
      stripe_subscription_id 'asdfasdfasdf'
      subscription_activated_at nil
      subscription_expires_at {DateTime.current + 1.month}
    end
    
    trait :sub_expired do
			stripe_customer_id 'aoskjdfoasjfd'
			card_brand 'visa'
      card_exp_month '04'
      card_exp_year '24'
      card_last4 '4242'
      stripe_subscription_id 'asdfasdfasdf'
      subscription_activated_at {DateTime.current - 1.months - 1.days}
      subscription_expires_at {DateTime.current - 1.days}
		end
  end

  factory :executive do
    email 'executive@freshandtumble.com'
    password 'password'
    password_confirmation 'password'
  end

  factory :client do
    name 'acme salon'
    phone '5555555555'
    email 'acmesalon@sample.com'
    special_notes 'nothing here'
    contact_person 'adam smith'
    area_of_business 'nail salon'
    monday true
    tuesday true
    wednesday true
    thursday true
    friday true
    saturday true
    sunday true
    pickup_window 'afternoon'
    price_per_pound 1.49
    card_brand 'visa'
    card_exp_month '04'
    card_exp_year '24'
    card_last4 '4242'
  end

  factory :address do
    street_address '1233 s 117th st'
    unit_number '12A'
    city 'Seattle'
    state 'Washington'
    zipcode '98168'
    pick_up_directions 'Front Door'

    trait :invalid do
      zipcode '55555'
    end

    trait :with_fake_geocode do
      latitude -12334
      longitude -4567
    end
  end

  factory :order do
    # full_address MUST MERGE
    # routable_address MUST MERGE
    pick_up_date Date.tomorrow
    pick_up_time '6:00AM'
    detergent %w[tide_original tide_hypoallergenic].sample
    softener %w[bounce snuggle hypo_allergenic no_softener].sample
    reference_code "LB-#{SecureRandom.hex(5)}".upcase
  end

  factory :transaction do
    # order_id MUST MERGE
    # customer_email MUST MERGE
    # subtotal MUST MERGE
    # tax MUST MERGE
    # grandtotal MUST MERGE
    # weight MUST MERGE
    # price_per_pound MUST MERGE
    trait :paid do
      # customer_email MUST MERGE
        paid 'paid'
        stripe_customer_id '123123'
        card_brand 'visa'
        card_exp_month '05'
        card_exp_year '2024'
        card_last4 '4242'
        stripe_response 'success'
        stripe_charge_id 'abc123'
				order_reference_code "Order: LB-#{SecureRandom.hex(5)}".upcase
				order_id 1
				subtotal {rand(11.1..100).round(2).to_d}
				tax {rand(11.1..100).round(2).to_d}
				grandtotal {rand(11.1..100).round(2).to_d}
				wash_hours_saved {rand(1..10)}
				region_name 'seattle'
				tax_rate {0.101}
			end
  end

  factory :support_ticket do
    # order_id MUST MERGE
    # setting the attribute concern will cause app crash it is a reserved keyword, merge on create instead
    subject 'New Support Ticket | Order: LB-123445'
    body "My order got lost and I don't know what to do"
    order_reference_code 'LB-123445'
    customer_name 'Mike Arriaga'
    customer_email 'arriaga562@gmail.com'
    customer_phone '5627872684'
    pick_up_appointment 'Friday 13th at 7:30AM'
  end

  factory :appointment do
    order_id 1
    pick_up_date Time.current
    pick_up_time '6:00AM'
  end

  factory :worker do
    email 'm.arriaga.smb@gmail.com'
    full_name 'Mike Arriaga'
    # CLICKSEND TEST PHONE NUMBER (doesn't incure charges)
    phone '4055555555'
    # phone '5627872684'
    password 'password'
    password_confirmation 'password'

    trait :invalid_email do
      email 'aosidjf'
		end
		
		trait :with_region do
			# region must already exist
			region_id 1
		end
  end
  
  factory :worker_account_creation_code do
    code '1234567'
  end

  factory :courier_problem do
    created_at Date.current
    
    trait :delivery_problem do
      problem_encountered ['no_residential_access', 'business_closed'].sample
      occured_during_task 'deliver_to_customer'
      occured_during_step 'step3'
    end

    trait :pickup_problem do
      problem_encountered ['no_residential_access', 'business_closed', 'cannot_locate_order'].sample
      occured_during_task 'pickup_from_customer'
      occured_during_step 'step2'
    end

  end
end
