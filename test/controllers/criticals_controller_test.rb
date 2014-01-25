require 'test_helper'

class CriticalsControllerTest < ActionController::TestCase
  setup do
    @critical = criticals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:criticals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create critical" do
    assert_difference('Critical.count') do
      post :create, critical: { inspection_id: @critical.inspection_id, text: @critical.text }
    end

    assert_redirected_to critical_path(assigns(:critical))
  end

  test "should show critical" do
    get :show, id: @critical
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @critical
    assert_response :success
  end

  test "should update critical" do
    patch :update, id: @critical, critical: { inspection_id: @critical.inspection_id, text: @critical.text }
    assert_redirected_to critical_path(assigns(:critical))
  end

  test "should destroy critical" do
    assert_difference('Critical.count', -1) do
      delete :destroy, id: @critical
    end

    assert_redirected_to criticals_path
  end
end
