require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Frankie" do
      assert_equal 'Frankie', users(:frankie).name
      assert_equal 'frankie@email.com', users(:frankie).email
  end

  test "Norma" do
      assert_equal 'Norma', users(:norma).name
      assert_equal 'norma@email.com', users(:norma).email
  end
end
