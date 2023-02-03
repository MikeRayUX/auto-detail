# frozen_string_literal: true

# Example rake file structure
# Define a namespace for the task
namespace :jwt do
  # Give a description for the task
  desc 'Clear all stale jti tokens'
  # Define the task
  task destroy_stale_tokens: :environment do
    @tokens = JwtBlacklist.where('created_at <= ?', 24.hours.ago)
    @tokens.destroy_all
  end
end
