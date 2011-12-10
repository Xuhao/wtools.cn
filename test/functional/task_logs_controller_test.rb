require 'test_helper'

class TaskLogsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:task_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task_log" do
    assert_difference('TaskLog.count') do
      post :create, :task_log => { }
    end

    assert_redirected_to task_log_path(assigns(:task_log))
  end

  test "should show task_log" do
    get :show, :id => task_logs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => task_logs(:one).to_param
    assert_response :success
  end

  test "should update task_log" do
    put :update, :id => task_logs(:one).to_param, :task_log => { }
    assert_redirected_to task_log_path(assigns(:task_log))
  end

  test "should destroy task_log" do
    assert_difference('TaskLog.count', -1) do
      delete :destroy, :id => task_logs(:one).to_param
    end

    assert_redirected_to task_logs_path
  end
end
