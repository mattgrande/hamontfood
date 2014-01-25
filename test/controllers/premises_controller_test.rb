require 'test_helper'

class PremisesControllerTest < ActionController::TestCase
  setup do
    @premise = premises(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:premises)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create premise" do
    assert_difference('Premise.count') do
      post :create, premise: { address: @premise.address, id: @premise.id, name: @premise.name, premise_type: @premise.premise_type }
    end

    assert_redirected_to premise_path(assigns(:premise))
  end

  test "should show premise" do
    get :show, id: @premise
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @premise
    assert_response :success
  end

  test "should update premise" do
    patch :update, id: @premise, premise: { address: @premise.address, id: @premise.id, name: @premise.name, premise_type: @premise.premise_type }
    assert_redirected_to premise_path(assigns(:premise))
  end

  test "should destroy premise" do
    assert_difference('Premise.count', -1) do
      delete :destroy, id: @premise
    end

    assert_redirected_to premises_path
  end
end
