require 'test_helper'

class ActionTakensControllerTest < ActionController::TestCase
  setup do
    @action_taken = action_takens(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:action_takens)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create action_taken" do
    assert_difference('ActionTaken.count') do
      post :create, action_taken: { inspection_id: @action_taken.inspection_id, text: @action_taken.text }
    end

    assert_redirected_to action_taken_path(assigns(:action_taken))
  end

  test "should show action_taken" do
    get :show, id: @action_taken
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @action_taken
    assert_response :success
  end

  test "should update action_taken" do
    patch :update, id: @action_taken, action_taken: { inspection_id: @action_taken.inspection_id, text: @action_taken.text }
    assert_redirected_to action_taken_path(assigns(:action_taken))
  end

  test "should destroy action_taken" do
    assert_difference('ActionTaken.count', -1) do
      delete :destroy, id: @action_taken
    end

    assert_redirected_to action_takens_path
  end
end
