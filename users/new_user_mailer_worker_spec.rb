# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Users::NewUserMailerWorker, type: :worker do
  describe 'worker send new user a signup email' do
    before do
      DatabaseCleaner.clean_with(:truncation)
      Sidekiq::Testing.inline!
      ActionMailer::Base.deliveries.clear
      @user = User.create!(attributes_for(:user))

      @worker = Users::NewUserMailerWorker
    end

    after do
      ActionMailer::Base.deliveries.clear
    end

    it 'adds the jobs the jobs array' do
      Sidekiq::Testing.fake!
      @worker.perform_async(@user.id)

      expect(@worker.jobs.size).to eq(1)
    end

    it 'sends the email' do
      @worker.perform_async(@user.id)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
