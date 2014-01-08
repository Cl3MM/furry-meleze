require 'test_helper'

class CollecteursControllerTest < ActionController::TestCase
  setup do
    @collecteur = collecteurs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collecteurs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collecteur" do
    assert_difference('Collecteur.count') do
      post :create, collecteur: { adresse: @collecteur.adresse, cp: @collecteur.cp, email: @collecteur.email, fax: @collecteur.fax, nom: @collecteur.nom, nomenclature: @collecteur.nomenclature, responsable: @collecteur.responsable, siret: @collecteur.siret, tel: @collecteur.tel, vile: @collecteur.vile }
    end

    assert_redirected_to collecteur_path(assigns(:collecteur))
  end

  test "should show collecteur" do
    get :show, id: @collecteur
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @collecteur
    assert_response :success
  end

  test "should update collecteur" do
    put :update, id: @collecteur, collecteur: { adresse: @collecteur.adresse, cp: @collecteur.cp, email: @collecteur.email, fax: @collecteur.fax, nom: @collecteur.nom, nomenclature: @collecteur.nomenclature, responsable: @collecteur.responsable, siret: @collecteur.siret, tel: @collecteur.tel, vile: @collecteur.vile }
    assert_redirected_to collecteur_path(assigns(:collecteur))
  end

  test "should destroy collecteur" do
    assert_difference('Collecteur.count', -1) do
      delete :destroy, id: @collecteur
    end

    assert_redirected_to collecteurs_path
  end
end
