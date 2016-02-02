require 'test_helper'

class SiteErrorsControllerTest < ActionController::TestCase
  setup do
    @site_error = site_errors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:site_errors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site_error" do
    assert_difference('SiteError.count') do
      post :create, site_error: { message: @site_error.message, site_id: @site_error.site_id }
    end

    assert_redirected_to site_error_path(assigns(:site_error))
  end

  test "should show site_error" do
    get :show, id: @site_error
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @site_error
    assert_response :success
  end

  test "should update site_error" do
    patch :update, id: @site_error, site_error: { message: @site_error.message, site_id: @site_error.site_id }
    assert_redirected_to site_error_path(assigns(:site_error))
  end

  test "should destroy site_error" do
    assert_difference('SiteError.count', -1) do
      delete :destroy, id: @site_error
    end

    assert_redirected_to site_errors_path
  end
end
