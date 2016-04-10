require 'test_helper'

class LoginControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get login_login_url
    assert_response :success
  end

end
