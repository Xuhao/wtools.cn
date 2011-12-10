require 'test_helper'

class WebsitesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:websites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create website" do
    assert_difference('Website.count') do
      post :create, :website => { }
    end

    assert_redirected_to website_path(assigns(:website))
  end

  test "should show website" do
    get :show, :id => websites(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => websites(:one).to_param
    assert_response :success
  end

  test "should update website" do
    put :update, :id => websites(:one).to_param, :website => { }
    assert_redirected_to website_path(assigns(:website))
  end

  test "should destroy website" do
    assert_difference('Website.count', -1) do
      delete :destroy, :id => websites(:one).to_param
    end

    assert_redirected_to websites_path
  end
end
