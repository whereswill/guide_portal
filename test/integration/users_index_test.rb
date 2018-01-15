require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @non_active = users(:malory)
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
    assert_select 'span', text: 'Verified', count: 0
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    assert_select 'a[href=?]', user_path(@non_active), text: @non_active.name, count: 0
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.all.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
        if user.activated?
          assert_select 'span', text: '| Verified'
        else
          assert_select 'a[href=?]', account_activation_path(user), text: 'Resend verification email'
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
end
