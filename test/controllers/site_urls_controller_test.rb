require 'test_helper'

class SiteUrlsControllerTest < ActionController::TestCase
  setup do
    @site_url = site_urls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:site_urls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create site_url" do
    assert_difference('SiteUrl.count') do
      post :create, site_url: { site_id: @site_url.site_id, status: @site_url.status, ua_code: @site_url.ua_code, url: @site_url.url }
    end

    assert_redirected_to site_url_path(assigns(:site_url))
  end

  test "should show site_url" do
    get :show, id: @site_url
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @site_url
    assert_response :success
  end

  test "should update site_url" do
    patch :update, id: @site_url, site_url: { site_id: @site_url.site_id, status: @site_url.status, ua_code: @site_url.ua_code, url: @site_url.url }
    assert_redirected_to site_url_path(assigns(:site_url))
  end

  test "should destroy site_url" do
    assert_difference('SiteUrl.count', -1) do
      delete :destroy, id: @site_url
    end

    assert_redirected_to site_urls_path
  end
end
