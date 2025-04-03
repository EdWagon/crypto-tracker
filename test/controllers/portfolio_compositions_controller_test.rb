require "test_helper"

class PortfolioCompositionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get portfolio_compositions_index_url
    assert_response :success
  end
end
