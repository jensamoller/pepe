require 'test_helper'

class FoosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:foos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_foo
    assert_difference('Foo.count') do
      post :create, :foo => { }
    end

    assert_redirected_to foo_path(assigns(:foo))
  end

  def test_should_show_foo
    get :show, :id => foos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => foos(:one).id
    assert_response :success
  end

  def test_should_update_foo
    put :update, :id => foos(:one).id, :foo => { }
    assert_redirected_to foo_path(assigns(:foo))
  end

  def test_should_destroy_foo
    assert_difference('Foo.count', -1) do
      delete :destroy, :id => foos(:one).id
    end

    assert_redirected_to foos_path
  end
end
