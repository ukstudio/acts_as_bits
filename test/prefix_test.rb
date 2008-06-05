require File.dirname(__FILE__) + '/test_helper'

class PrefixTest < Test::Unit::TestCase
  class User < ActiveRecord::Base
    set_table_name :mixins
    acts_as_bits :flags, %w( login show ), :prefix=>true
  end

  def test_not_respond_to_native_name
    user = User.new

    assert ! user.respond_to?(:login)
    assert ! user.respond_to?(:show)
  end

  def test_respond_to_prefixed_name
    user = User.new

    assert_respond_to user, :flag_login?
    assert_respond_to user, :flag_login=
    assert_respond_to user, :flag_login
    assert_respond_to user, :flag_show?
    assert_respond_to user, :flag_show=
    assert_respond_to user, :flag_show
  end

  def test_respond_to_prefix_method
    user = User.new
    assert_respond_to user, :flag?
  end

  def test_setter
    user = User.new
    assert_equal false, user.flag_login?
    user.flag_login = true
    assert_equal true , user.flag_login?
  end

  def test_prefix_method
    user = User.new
    assert_equal false, user.flag?(:login)
    assert_equal false, user.flag?(:show)
    assert_equal false, user.flag?("login")
    assert_equal false, user.flag?("show")

    user.flag_login = true
    assert_equal true,  user.flag?(:login)
    assert_equal false, user.flag?(:show)
    assert_equal true,  user.flag?("login")
    assert_equal false, user.flag?("show")
  end
end
