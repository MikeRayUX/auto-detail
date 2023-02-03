# frozen_string_literal: true

require 'test_helper'

class AvailabilityMailingListControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get availability_mailing_list_new_url
    assert_response :success
  end

  test 'should get create' do
    get availability_mailing_list_create_url
    assert_response :success
  end
end
