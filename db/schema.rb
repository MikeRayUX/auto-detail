# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_22_235437) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id"
    t.string "unit_number"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zipcode"
    t.string "street_address"
    t.integer "worker_id"
    t.float "latitude"
    t.float "longitude"
    t.integer "partner_id"
    t.string "pick_up_directions"
    t.bigint "region_id"
    t.bigint "client_id"
    t.string "phone"
    t.bigint "washer_id"
    t.index ["client_id"], name: "index_addresses_on_client_id"
    t.index ["partner_id"], name: "index_addresses_on_partner_id"
    t.index ["region_id"], name: "index_addresses_on_region_id"
    t.index ["user_id"], name: "index_addresses_on_user_id"
    t.index ["washer_id"], name: "index_addresses_on_washer_id"
    t.index ["worker_id"], name: "index_addresses_on_worker_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "order_id"
    t.datetime "pick_up_date"
    t.string "pick_up_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_appointments_on_order_id"
    t.index ["pick_up_date", "pick_up_time"], name: "index_appointments_on_pick_up_date_and_pick_up_time", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "special_notes"
    t.string "contact_person"
    t.string "area_of_business"
    t.integer "pickup_window"
    t.string "card_brand"
    t.string "card_exp_month"
    t.string "card_exp_year"
    t.string "card_last4"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "price_per_pound", precision: 12, scale: 2
    t.string "phone"
    t.string "stripe_customer_id"
    t.boolean "monday", default: false
    t.boolean "tuesday", default: false
    t.boolean "wednesday", default: false
    t.boolean "thursday", default: false
    t.boolean "friday", default: false
    t.boolean "saturday", default: false
    t.boolean "sunday", default: false
    t.boolean "active", default: true
  end

  create_table "commercial_pickups", force: :cascade do |t|
    t.bigint "transaction_id"
    t.bigint "client_id"
    t.string "full_address"
    t.string "routable_address"
    t.string "reference_code"
    t.string "pick_up_directions"
    t.string "bags_code"
    t.integer "pick_up_window"
    t.integer "detergent"
    t.integer "softener"
    t.integer "global_status", default: 0
    t.integer "bags_collected"
    t.datetime "pick_up_date"
    t.datetime "picked_up_from_client_at"
    t.datetime "dropped_off_to_partner_at"
    t.datetime "picked_up_from_partner_at"
    t.datetime "delivered_to_client_at"
    t.decimal "weight", precision: 12, scale: 2
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "partner_location_id"
    t.integer "problem_encountered"
    t.integer "courier_stated_delivered_location"
    t.bigint "address_id"
    t.decimal "subtotal", precision: 12, scale: 2
    t.decimal "tax", precision: 12, scale: 2
    t.decimal "grandtotal", precision: 12, scale: 2
    t.decimal "tax_rate", precision: 12, scale: 2
    t.decimal "client_price_per_pound", precision: 12, scale: 2
    t.index ["address_id"], name: "index_commercial_pickups_on_address_id"
    t.index ["client_id"], name: "index_commercial_pickups_on_client_id"
    t.index ["partner_location_id"], name: "index_commercial_pickups_on_partner_location_id"
    t.index ["reference_code"], name: "index_commercial_pickups_on_reference_code"
    t.index ["transaction_id"], name: "index_commercial_pickups_on_transaction_id"
  end

  create_table "courier_problems", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "worker_id"
    t.integer "occured_during_task"
    t.integer "occured_during_step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.integer "problem_encountered"
    t.index ["order_id"], name: "index_courier_problems_on_order_id"
    t.index ["worker_id"], name: "index_courier_problems_on_worker_id"
  end

  create_table "coverage_areas", force: :cascade do |t|
    t.string "zipcode"
    t.string "state"
    t.string "county"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["city"], name: "index_coverage_areas_on_city"
    t.index ["region_id"], name: "index_coverage_areas_on_region_id"
    t.index ["zipcode"], name: "index_coverage_areas_on_zipcode", unique: true
  end

  create_table "email_sends", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "washer_id"
    t.bigint "sendgrid_email_id"
    t.integer "status"
    t.string "api_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sendgrid_email_id"], name: "index_email_sends_on_sendgrid_email_id"
    t.index ["user_id"], name: "index_email_sends_on_user_id"
    t.index ["washer_id"], name: "index_email_sends_on_washer_id"
  end

  create_table "executives", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_executives_on_email", unique: true
    t.index ["reset_password_token"], name: "index_executives_on_reset_password_token", unique: true
  end

  create_table "holidays", force: :cascade do |t|
    t.string "title"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti"
  end

  create_table "new_orders", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "washer_id"
    t.bigint "region_id"
    t.string "ref_code"
    t.integer "detergent"
    t.integer "softener"
    t.integer "bag_count"
    t.datetime "scheduled"
    t.datetime "picked_up_at"
    t.datetime "delivered_at"
    t.datetime "est_delivery"
    t.float "tax_rate"
    t.decimal "subtotal", precision: 12, scale: 2
    t.decimal "tax", precision: 12, scale: 2
    t.decimal "grandtotal", precision: 12, scale: 2
    t.decimal "tip", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.string "unit_number"
    t.string "directions"
    t.datetime "accept_by"
    t.datetime "accepted_at"
    t.datetime "cancelled_at"
    t.datetime "completed_at"
    t.string "stripe_charge_id"
    t.decimal "washer_pay", precision: 12, scale: 2
    t.decimal "profit", precision: 12, scale: 2
    t.string "zipcode"
    t.integer "customer_rating"
    t.datetime "enroute_for_pickup_at"
    t.datetime "arrived_for_pickup_at"
    t.integer "status", default: 0
    t.string "full_address"
    t.float "address_lat"
    t.float "address_lng"
    t.integer "pickup_type"
    t.string "bag_codes"
    t.string "wash_notes"
    t.decimal "washer_final_pay", precision: 12, scale: 2
    t.decimal "washer_ppb", precision: 12, scale: 2
    t.string "stripe_transfer_id"
    t.string "stripe_transfer_error"
    t.string "payout_desc"
    t.string "readable_delivered_at"
    t.datetime "est_pickup_by"
    t.string "stripe_refund_id"
    t.decimal "pmt_processing_fee", precision: 12, scale: 2
    t.datetime "washer_adjusted_bag_count_at"
    t.decimal "refunded_amount", precision: 12, scale: 2
    t.integer "delivery_location"
    t.string "delivery_photo_base64"
    t.float "washer_pay_percentage"
    t.decimal "failed_pickup_fee", precision: 12, scale: 2
    t.decimal "bag_price", precision: 12, scale: 2
    t.index ["ref_code"], name: "index_new_orders_on_ref_code"
    t.index ["region_id"], name: "index_new_orders_on_region_id"
    t.index ["user_id"], name: "index_new_orders_on_user_id"
    t.index ["washer_id"], name: "index_new_orders_on_washer_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "user_id"
    t.integer "notification_method"
    t.integer "event"
    t.boolean "sent"
    t.datetime "sent_at"
    t.string "send_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_body"
    t.integer "worker_id"
    t.bigint "new_order_id"
    t.index ["order_id"], name: "index_notifications_on_order_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
    t.index ["worker_id"], name: "index_notifications_on_worker_id"
  end

  create_table "offer_events", force: :cascade do |t|
    t.bigint "washer_id"
    t.bigint "new_order_id"
    t.integer "event_type"
    t.string "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["new_order_id"], name: "index_offer_events_on_new_order_id"
    t.index ["washer_id"], name: "index_offer_events_on_washer_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.decimal "order_total", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference_code"
    t.string "pick_up_time"
    t.integer "worker_id"
    t.string "full_address"
    t.float "customer_lat"
    t.float "customer_long"
    t.datetime "pick_up_date"
    t.string "bags_code"
    t.integer "bags_collected"
    t.datetime "picked_up_from_customer_at"
    t.datetime "dropped_off_to_partner_at"
    t.datetime "picked_up_from_partner_at"
    t.datetime "delivered_to_customer_at"
    t.float "courier_weight"
    t.float "partner_reported_weight"
    t.integer "global_status", default: 0
    t.integer "pick_up_from_customer_status", default: 0
    t.integer "drop_off_to_partner_status", default: 0
    t.integer "partner_location_id"
    t.boolean "marked_as_ready_for_pickup_from_partner", default: false
    t.integer "pick_up_from_partner_status", default: 0
    t.integer "deliver_to_customer_status", default: 0
    t.string "courier_stated_delivered_location"
    t.integer "delivery_attempts", default: 0
    t.integer "checkout_holding_order_status"
    t.string "routable_address"
    t.integer "detergent"
    t.integer "softener"
    t.integer "region_pricing_id"
    t.bigint "client_id"
    t.boolean "unwashable_items", default: false
    t.string "pick_up_directions"
    t.index ["client_id"], name: "index_orders_on_client_id"
    t.index ["partner_location_id"], name: "index_orders_on_partner_location_id"
    t.index ["pick_up_time"], name: "index_orders_on_pick_up_time"
    t.index ["reference_code"], name: "index_orders_on_reference_code"
    t.index ["region_pricing_id"], name: "index_orders_on_region_pricing_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["worker_id"], name: "index_orders_on_worker_id"
  end

  create_table "partner_locations", force: :cascade do |t|
    t.string "street_address"
    t.string "zipcode"
    t.string "state"
    t.string "city"
    t.string "unit_number"
    t.string "region"
    t.float "latitude"
    t.float "longitude"
    t.string "services_offered"
    t.decimal "price_per_lb", precision: 12, scale: 2
    t.integer "turnaround_time_hours"
    t.string "business_name"
    t.string "business_phone"
    t.string "business_email"
    t.string "business_website"
    t.string "contact_name"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "monday_hours"
    t.string "tuesday_hours"
    t.string "wednesday_hours"
    t.string "thursday_hours"
    t.string "friday_hours"
    t.string "saturday_hours"
    t.string "sunday_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questionaires", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "subject"
    t.string "answer_selection"
    t.string "elaboration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_questionaires_on_user_id"
  end

  create_table "region_pricings", force: :cascade do |t|
    t.string "region"
    t.decimal "price_per_pound", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "tax_rate"
    t.decimal "minimum_charge", precision: 12, scale: 2
  end

  create_table "regions", force: :cascade do |t|
    t.string "area"
    t.float "tax_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "washer_capacity", default: 0
    t.decimal "price_per_bag", precision: 12, scale: 2
    t.float "washer_pay_percentage"
    t.string "stripe_tax_rate_id"
    t.datetime "last_washer_offer_check"
    t.integer "max_concurrent_offers"
    t.decimal "failed_pickup_fee", precision: 12, scale: 2
    t.string "business_open"
    t.string "business_close"
  end

  create_table "sendgrid_emails", force: :cascade do |t|
    t.string "template_id"
    t.string "description"
    t.string "preview_url"
    t.text "content_summary"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "site_banners", force: :cascade do |t|
    t.integer "display_location"
    t.string "body_text"
    t.string "link_text"
    t.string "link_url"
    t.string "alt_url"
    t.string "conditional"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "stripe_product_id"
    t.string "stripe_price_id"
    t.decimal "price", precision: 12, scale: 2
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_ticket_replies", force: :cascade do |t|
    t.bigint "support_ticket_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_ticket_id"], name: "index_support_ticket_replies_on_support_ticket_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "order_id"
    t.string "subject"
    t.string "body"
    t.string "order_reference_code"
    t.string "customer_name"
    t.string "customer_email"
    t.string "customer_phone"
    t.string "pick_up_appointment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "concern"
    t.datetime "closed_at"
    t.datetime "last_viewed"
    t.bigint "washer_id"
    t.index ["order_id"], name: "index_support_tickets_on_order_id"
    t.index ["washer_id"], name: "index_support_tickets_on_washer_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "user_id"
    t.integer "paid"
    t.string "stripe_customer_id"
    t.string "card_brand"
    t.string "card_exp_month"
    t.string "card_exp_year"
    t.string "card_last4"
    t.string "customer_email"
    t.string "order_reference_code"
    t.decimal "subtotal", precision: 12, scale: 2
    t.decimal "tax", precision: 12, scale: 2
    t.decimal "grandtotal", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_response"
    t.string "stripe_charge_id"
    t.float "wash_hours_saved"
    t.string "region_name"
    t.float "tax_rate"
    t.decimal "weight", precision: 12, scale: 2
    t.decimal "price_per_pound", precision: 12, scale: 2
    t.bigint "client_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "new_order_id"
    t.string "new_order_reference_code"
    t.string "stripe_subscription_id"
    t.index ["client_id"], name: "index_transactions_on_client_id"
    t.index ["order_id"], name: "index_transactions_on_order_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "card_brand"
    t.string "card_exp_month"
    t.string "card_exp_year"
    t.string "card_last4"
    t.string "stripe_customer_id"
    t.string "phone"
    t.string "full_name"
    t.datetime "deleted_at"
    t.boolean "sms_enabled", default: true
    t.boolean "promotional_emails", default: true
    t.boolean "business_review_left", default: false
    t.string "stripe_subscription_id"
    t.datetime "subscription_activated_at"
    t.datetime "subscription_expires_at"
    t.string "otp_secret_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wait_lists", force: :cascade do |t|
    t.string "zipcode"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "invite_sent_at"
    t.index ["zipcode"], name: "index_wait_lists_on_zipcode"
  end

  create_table "washers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.bigint "region_id"
    t.string "encrypted_ssn"
    t.string "encrypted_ssn_iv"
    t.string "encrypted_date_of_birth"
    t.string "encrypted_date_of_birth_iv"
    t.string "encrypted_phone"
    t.string "encrypted_phone_iv"
    t.datetime "deactivated_at"
    t.datetime "activated_at"
    t.string "otp_secret_key"
    t.boolean "authenticate_with_otp", default: true
    t.string "encrypted_drivers_license"
    t.string "encrypted_drivers_license_iv"
    t.datetime "completed_app_intro_at"
    t.datetime "tos_accepted_at"
    t.datetime "eligibility_completed_at"
    t.datetime "background_check_submitted_at"
    t.string "stripe_account_id"
    t.datetime "tax_agreement_accepted_at"
    t.datetime "background_check_approved_at"
    t.datetime "insurance_agreement_accepted_at"
    t.string "full_name"
    t.datetime "last_online_at"
    t.float "current_lat"
    t.float "current_lng"
    t.boolean "payoutable_as_ic", default: true
    t.boolean "live_within_region"
    t.boolean "min_age"
    t.boolean "legal_to_work"
    t.boolean "valid_drivers_license"
    t.boolean "valid_car_insurance_coverage"
    t.boolean "valid_ssn"
    t.boolean "reliable_transportation"
    t.boolean "can_lift_30_lbs"
    t.boolean "has_disability"
    t.boolean "has_equipment"
    t.boolean "consent_to_background_check"
    t.datetime "app_invitation_sent_at"
    t.index ["email"], name: "index_washers_on_email", unique: true
    t.index ["region_id"], name: "index_washers_on_region_id"
    t.index ["reset_password_token"], name: "index_washers_on_reset_password_token", unique: true
  end

  create_table "work_sessions", force: :cascade do |t|
    t.bigint "washer_id"
    t.datetime "last_checked_in_at"
    t.datetime "terminated_at"
    t.string "secure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["washer_id"], name: "index_work_sessions_on_washer_id"
  end

  create_table "worker_account_creation_codes", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "phone"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["email"], name: "index_workers_on_email", unique: true
    t.index ["region_id"], name: "index_workers_on_region_id"
    t.index ["reset_password_token"], name: "index_workers_on_reset_password_token", unique: true
  end

end
