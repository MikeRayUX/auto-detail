# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Users::Dashboards::Settings::UserUpdatedPasswordMailerWorker, type: :worker do
  describe 'worker sends an email notifying the user that their password was recently changed' do
    before do
      Sidekiq::Testing.inline!
      DatabaseCleaner.clean_with(:truncation)
      ActionMailer::Base.deliveries.clear
      @user = User.create!(
        full_name: 'John Doe',
        email: 'jdoe@testsample.com',
        password: 'password',
        password_confirmation: 'password',
        phone: '5555555555',
        card_brand: 'visa',
        card_exp_month: '05',
        card_exp_year: '2020',
        card_last4: 5555
      )
      @worker = Users::Dashboards::Settings::UserUpdatedPasswordMailerWorker
      @timestamp = DateTime.current.strftime('%m/%d/%Y at %I:%M%P')
    end

    after do
      DatabaseCleaner.clean_with(:truncation)
      ActionMailer::Base.deliveries.clear
    end

    it 'adds the jobs to the jobs array' do
      Sidekiq::Testing.fake!
      @worker.perform_async(
        @user.id,
        @timestamp
      )

      expect(@worker.jobs.size).to eq(1)
    end

    it 'sends an email' do
      @worker.perform_async(
        @user.id,
        @timestamp
      )
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
