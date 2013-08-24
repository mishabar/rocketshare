require 'test_helper'

class ShareControllerTest < ActionController::TestCase
  test "should get share" do
    get :share
    assert_response :success
  end

end
