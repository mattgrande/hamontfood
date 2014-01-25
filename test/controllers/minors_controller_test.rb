require 'test_helper'

class MinorsControllerTest < ActionController::TestCase
  setup do
    @minor = minors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:minors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create minor" do
    assert_difference('Minor.count') do
      post :create, minor: { inspection_id: @minor.inspection_id, text: @minor.text }
    end

    assert_redirected_to minor_path(assigns(:minor))
  end

  test "should show minor" do
    get :show, id: @minor
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @minor
    assert_response :success
  end

  test "should update minor" do
    patch :update, id: @minor, minor: { inspection_id: @minor.inspection_id, text: @minor.text }
    assert_redirected_to minor_path(assigns(:minor))
  end

  test "should destroy minor" do
    assert_difference('Minor.count', -1) do
      delete :destroy, id: @minor
    end

    assert_redirected_to minors_path
  end
end
