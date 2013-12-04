require 'test_helper'

class ProducteursControllerTest < ActionController::TestCase
  setup do
    @producteur = producteurs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:producteurs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create producteur" do
    assert_difference('Producteur.count') do
      post :create, producteur: {  }
    end

    assert_redirected_to producteur_path(assigns(:producteur))
  end

  test "should show producteur" do
    get :show, id: @producteur
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @producteur
    assert_response :success
  end

  test "should update producteur" do
    put :update, id: @producteur, producteur: {  }
    assert_redirected_to producteur_path(assigns(:producteur))
  end

  test "should destroy producteur" do
    assert_difference('Producteur.count', -1) do
      delete :destroy, id: @producteur
    end

    assert_redirected_to producteurs_path
  end
end
