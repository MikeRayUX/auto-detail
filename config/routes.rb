Rails.application.routes.draw do
  require 'sidekiq/web'

  authenticate :executive do
    mount Sidekiq::Web => '/sidekiq-a673d7a7-c14d-4982-98fe-45d192292dd9'
  end

  mount StripeEvent::Engine, at: '/stripe-cd4a0db6-36b4-4b6d-baba-58877e618553'

  root to: 'static_pages/home_pages#show'

  devise_for :users,
             path: 'users',
             controllers: {
               sessions: 'users/sessions', passwords: 'users/passwords'
             }

  devise_for :workers,
             path: 'workers',
             controllers: {
               sessions: 'workers/sessions', passwords: 'workers/passwords'
             }

  devise_for :executives,
             skip: %i[registrations passwords],
             path: 'executives',
             controllers: {
               sessions: 'executives/sessions',
               passwords: 'executives/passwords'
             }

  devise_scope :user do
    get '/signin', to: 'users/sessions#new'
    get '/signup', to: 'users/registrations#new'
  end

  get '/commercial', to: 'static_pages/commercial_pages#show'
  get '/pricing', to: 'static_pages/home_pages#show'
  get '/termsofservice', to: 'static_pages/tos_pages#show'
  get '/contactus', to: 'static_pages/contact_pages#new'
  get '/washers/apply', to: 'static_pages/washer_pages#new'
  get '/washers/application_success', to: 'static_pages/washer_pages#index'
  get '/privacypolicy', to: 'static_pages/privacy_policy_pages#show'

  namespace :static_pages do
    resource :contact_pages, only: %i[create show]

    resource :washer_pages, only: %i[create]
  end

  namespace :users do
    namespace :service_areas do
      resource :verify_zipcodes, only: %i[new create]
      resource :wait_lists, only: %i[new create show]
    end

    resource :registrations, only: %i[create]
    resources :resolve_setups, only: %i[new index create]
    resource :current_payment_methods, only: %i[show update]
    resource :outside_coverage_areas, only: %i[show]

    namespace :orders do
      resource :orders, only: %i[show update]
    end

    namespace :new_orders do
      resource :new_orders, only: %i[show]
    end

    namespace :dashboards do
      resources :homes, only: %i[index]
      resources :orders_overviews, only: %i[index]
      resource :support_tickets, only: %i[new show create]
      resources :billings, only: %i[index]

      namespace :settings do
        resource :info_summaries, only: %i[show]
        resource :update_names, only: %i[show update]
        resource :update_phones, only: %i[show update]
        resource :update_emails, only: %i[show update]
        resource :update_addresses, only: %i[show update]
        resource :update_payments, only: %i[show update]
        resource :update_subscriptions, only: %i[show destroy]
        resource :update_notifications, only: %i[show update]
        resource :cancel_accounts, only: %i[new create]
      end

      namespace :new_order_flow do
        resources :outside_service_areas, only: %i[index]
        resource :pickups, only: %i[new]
        resources :pickup_estimations, only: %i[index]
        resources :scheduled_pickups, only: %i[new]
        resources :confirm_pickups, only: %i[new create]
        resources :scheduled_timeslots, only: %i[index]
        resources :track_pickups, only: %i[show index]
        resources :refresh_wait_for_washers, only: %i[update]
        resources :cancel_pickups, only: %i[update]
      end
    end

    namespace :mailing_lists do
      resource :marketing_emails, only: %i[show]
    end
  end

  # namespace :api do
  #   namespace :v1 do
  #     resource :verify_zipcodes, only: %i[show]
  #     namespace :users do
  #       resource :resolve_auths, only: %i[show]
  #       resource :resolve_setups, only: %i[show create]
  #       resource :sessions, only: %i[create destroy]
  #       resource :forgot_passwords, only: %i[new update]
  #       resource :new_users, only: %i[create]
  #       resource :current_payment_methods, only: %i[show update]
  #       namespace :dashboards do
  #         resources :homes, only: %i[index]

  #         namespace :new_order_flow do
  #           resources :pickup_estimations, only: %i[index]
  #           resources :scheduled_pickups, only: %i[new create]
  #           resources :asap_pickups, only: %i[new create]
  #           resources :track_pickups, only: %i[show index]
  #           resources :refresh_wait_for_washers, only: %i[update]
  #           resources :cancel_pickups, only: %i[update]
  #         end

  #         resources :orders_overviews, only: %i[index]
  #         resources :support_tickets, only: %i[create]

  #         namespace :account_settings do
  #           resource :update_names, only: %i[update]
  #           resource :update_addresses, only: %i[update]
  #           resource :update_phones, only: %i[update]
  #           resource :update_pickup_directions, only: %i[update]
  #           resource :update_passwords, only: %i[update]
  #           resources :notifications_preferences, only: %i[index update]
  #         end
  #       end
  #     end

  #     namespace :washers do
  #       resources :registrations, only: %i[create]
  #       resources :sessions, only: %i[create destroy]
  #       resources :resolve_auths, only: %i[index]
  #       resources :otp_sessions, only: %i[create]
  #       resources :resend_otps, only: %i[create]
  #       resource :forgot_passwords, only: %i[new update]
  #       resource :reset_passwords, only: %i[update]
  #       resource :support_tickets, only: %i[create]

  #       namespace :activations do
  #         resources :resolve_setups, only: %i[index]
  #         resources :application_statuses, only: %i[index]
  #         resources :introductions, only: %i[new update]
  #         resources :terms_of_services, only: %i[new update]
  #         resources :eligibilities, only: %i[new update]
  #         resources :background_checks, only: %i[new update]
  #         resources :insurance_agreements, only: %i[new update]
  #         resources :tax_agreements, only: %i[new update]
  #         resources :direct_deposits, only: %i[new]
  #       end

  #       namespace :support do
  #         resources :earnings, only: %i[index]
  #       end

  #       resources :locations, only: %i[update]

  #       namespace :offers do
  #         resources :open_offers, only: %i[index]
  #         resource :accept_offers, only: %i[update]
  #       end

  #       namespace :work_flows do
  #         namespace :current_work do
  #           resource :start_offers, only: %i[show update]
  #           resource :abandon_offers, only: %i[update]
  #           resources :current_offers, only: %i[index]
  #           resource :offer_events, only: %i[create]
  #         end

  #         namespace :pickup_from_customers do
  #           resources :arrival_for_pickups, only: %i[update]
  #           resources :scanned_customer_bags, only: %i[update]
  #           namespace :rescue do
  #             resource :override_arrived_for_pickups, only: %i[update]
  #             resource :missing_bags, only: %i[update]
  #             resource :fail_pickup_offers, only: %i[update]
  #           end
  #         end

  #         namespace :process_orders do
  #           resource :wash_completes, only: %i[update]
  #         end

  #         namespace :deliver_to_customers do
  #           resource :deliveries, only: %i[update]
  #         end
  #       end
  #     end
  #   end
  # end

  namespace :washers do
    namespace :stripe_connect do
      resource :refreshes, only: %i[show]
      resource :returns, only: %i[show]
    end
  end

  namespace :clients do
    resource :addresses, only: %i[create update destroy]
  end

  # namespace :workers do
  #   resources :registration_with_codes, only: %i[new create]
  #   namespace :dashboards do
  #     resources :open_appointments, only: %i[index]
  #     resources :waiting_orders, only: %i[index]
  #     resources :processing_orders, only: %i[index]
  #     resources :ready_for_deliveries, only: %i[index]
  #     resources :reattempt_deliveries, only: %i[index]
  #     resources :holding_orders, only: %i[index]
  #     resource :processing_order_ready_state, only: %i[update]
  #   end
  #   namespace :courier do
  #     namespace :tasks do
  #       namespace :commercial do
  #         resource :pickup_from_clients, only: %i[show update]
  #         resource :dropoff_to_partners, only: %i[show update]
  #         resource :pickup_from_partners, only: %i[show update]
  #         resource :deliver_to_clients, only: %i[show update]
  #       end
  #       namespace :pickup_from_customer do
  #         resource :step1, only: %i[show update]
  #         resource :step2, only: %i[show update]
  #         resource :generate_pickup_labels, only: %i[new create]
  #         resource :step3, only: %i[show update]
  #         resource :step4, only: %i[show update]
  #       end
  #       namespace :dropoff_to_partner do
  #         resource :step1, only: %i[show update]
  #         resource :step2, only: %i[show update]
  #         resource :step3, only: %i[show update]
  #         resource :step4, only: %i[show update]
  #       end
  #       namespace :pickup_from_partner do
  #         resource :step1, only: %i[show update]
  #         resource :step2, only: %i[show update]
  #         resource :generate_delivery_labels, only: %i[new create]
  #         resource :step3, only: %i[show update]
  #         resource :step4, only: %i[show update]
  #       end
  #       namespace :deliver_to_customer do
  #         resource :step1, only: %i[show update]
  #         resource :step2, only: %i[show update]
  #         resource :step3, only: %i[show update]
  #       end
  #       namespace :checkout_holding_order do
  #         resource :step1, only: %i[show]
  #         resource :step2, only: %i[show update]
  #         resource :step3, only: %i[show update]
  #       end
  #       namespace :rescue do
  #         namespace :pickup_from_customer do
  #           namespace :residential_access do
  #             resource :contact_customers, only: %i[new show create]
  #           end
  #         end
  #         namespace :deliver_to_customer do
  #           namespace :residential_access do
  #             resource :contact_customers, only: %i[new show create]
  #           end
  #         end
  #         namespace :commercial do
  #           resource :pickup_from_clients, only: %i[show update]
  #         end
  #       end
  #     end
  #   end
  # end

  namespace :executives do
    namespace :dashboards do
      resources :homes, only: %i[index]
      resources :emails, only: %i[new create index destroy]
      resources :email_sends, only: %i[new create index]
      resources :wait_lists, only: %i[index update destroy]
      resources :holidays, only: %i[new create destroy index]

      namespace :users do
        resources :customers
        resource :bag_labels, only: %i[create]
        resource :ban_hammers, only: %i[update]
      end

      namespace :washers do
        resources :washers, only: %i[new create index show update destroy]
        resource :invitations, only: %i[update]
        resource :activations, only: %i[update]
        resource :deactivations, only: %i[update]
        resource :resend_activation_emails, only: %i[update]
        resource :background_checks, only: %i[update]
      end

      namespace :regions do
        resources :regions
      end

      namespace :commercial do
        resources :clients, only: %i[show update destroy edit index]
        resources :new_clients, only: %i[new create]
      end

      namespace :orders do
        resources :in_progresses, only: %i[index]
        resources :delivered, only: %i[index]
        resources :problem, only: %i[index]
      end

      namespace :new_orders do
        resources :new_orders, only: %i[index show]
      end

      resources :regions, only: %i[index create new show edit update destroy]

      resources :coverage_areas, only: %i[index new create destroy]

      namespace :support do
        resources :support_tickets, only: %i[index show update destroy]
        resource :delete_selected_support_tickets, only: %i[destroy]
        resource :close_tickets, only: %i[update]
        resource :reopen_tickets, only: %i[update]
        resource :support_ticket_replies, only: %i[create]
      end
    end
  end
end
