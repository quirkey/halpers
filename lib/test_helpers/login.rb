module LoginTestHelper
  
  def assert_redirected_to_login
    assert_redirected_to "/login"
  end
  
  def logout
    @request.session[:user] = nil
  end
  
end