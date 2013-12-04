require 'test_helper'

class DestinatairesControllerTest < ActionController::TestCase
  setup do
    @destinataire = destinataires(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:destinataires)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create destinataire" do
    assert_difference('Destinataire.count') do
      post :create, destinataire: {  }
    end

    assert_redirected_to destinataire_path(assigns(:destinataire))
  end

  test "should show destinataire" do
    get :show, id: @destinataire
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @destinataire
    assert_response :success
  end

  test "should update destinataire" do
    put :update, id: @destinataire, destinataire: {  }
    assert_redirected_to destinataire_path(assigns(:destinataire))
  end

  test "should destroy destinataire" do
    assert_difference('Destinataire.count', -1) do
      delete :destroy, id: @destinataire
    end

    assert_redirected_to destinataires_path
  end
end
