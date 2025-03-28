require "test_helper"

class WatchlistControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get watchlist_index_url
    assert_response :success
  end

  test "should get show" do
    get watchlist_show_url
    assert_response :success
  end

  test "should get create" do
    get watchlist_create_url
    assert_response :success
  end

  test "should get edit" do
    get watchlist_edit_url
    assert_response :success
  end

  test "should get update" do
    get watchlist_update_url
    assert_response :success
  end

  test "should get destroy" do
    get watchlist_destroy_url
    assert_response :success
  end

  test "should get new" do
    get watchlist_new_url
    assert_response :success
  end
end
