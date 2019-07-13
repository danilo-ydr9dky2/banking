require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Frankie" do
      assert_equal 'Frankie', users(:frankie).name
      assert_equal 'frankie@gmail.com', users(:frankie).email
      assert_same users(:frankie), users(:frankie).authenticate('lindy')
  end

  test "Norma" do
      assert_equal 'Norma', users(:norma).name
      assert_equal 'norma@gmail.com', users(:norma).email
      assert_same users(:norma), users(:norma).authenticate('hop')
  end
end
