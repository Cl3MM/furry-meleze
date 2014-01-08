require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  setup do
    @search = searches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:searches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create search" do
    assert_difference('Search.count') do
      post :create, search: { cp: @search.cp, date: @search.date, date_max: @search.date_max, date_min: @search.date_min, nom: @search.nom, nomenclature: @search.nomenclature, poids_max: @search.poids_max, poids_min: @search.poids_min, responsable: @search.responsable, siret: @search.siret, status: @search.status, ville: @search.ville }
    end

    assert_redirected_to search_path(assigns(:search))
  end

  test "should show search" do
    get :show, id: @search
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @search
    assert_response :success
  end

  test "should update search" do
    put :update, id: @search, search: { cp: @search.cp, date: @search.date, date_max: @search.date_max, date_min: @search.date_min, nom: @search.nom, nomenclature: @search.nomenclature, poids_max: @search.poids_max, poids_min: @search.poids_min, responsable: @search.responsable, siret: @search.siret, status: @search.status, ville: @search.ville }
    assert_redirected_to search_path(assigns(:search))
  end

  test "should destroy search" do
    assert_difference('Search.count', -1) do
      delete :destroy, id: @search
    end

    assert_redirected_to searches_path
  end
end
