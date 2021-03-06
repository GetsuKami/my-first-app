require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:little)
    remember(@user)
  end

  test "current user is remember user" do
  	assert_equal @user, current_user
  	assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
  	@user.update_attribute(:remember_digest, User.digest(User.new_token))
  	assert_not current_user
  end

end
