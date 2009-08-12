require 'test_helper'

class UrlsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:urls)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_url
    assert_difference('Url.count') do
      post :create, :url => { }
    end

    assert_redirected_to url_path(assigns(:url))
  end

  def test_should_show_url
    get :show, :id => urls(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => urls(:one).id
    assert_response :success
  end

  def test_should_update_url
    put :update, :id => urls(:one).id, :url => { }
    assert_redirected_to url_path(assigns(:url))
  end

  def test_should_destroy_url
    assert_difference('Url.count', -1) do
      delete :destroy, :id => urls(:one).id
    end

    assert_redirected_to urls_path
  end
end
