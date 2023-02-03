# frozen_string_literal: true

require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get home' do
    get static_pages_home_url
    assert_response :success
  end

  test 'should get signup' do
    get static_pages_signup_url
    assert_response :success
  end

  test 'should get pricing' do
    get static_pages_pricing_url
    assert_response :success
  end

  test 'should get faq' do
    get static_pages_faq_url
    assert_response :success
  end
end
