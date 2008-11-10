require File.dirname(__FILE__) + "/test_helper"

class MaskTest < Test::Unit::TestCase
  models :user

  def setup
#    User.find(:all).each(&:destroy)
  end

public
  def test_base_class
    assert_equal User, UserDeleted.base
  end

  def test_association_name_mappings
    assert User.association_name_mappings.include?("deleted")
  end

  def test_getter
    user = User.new
    assert_equal false, user.deleted
  end

  def test_setter
    count = UserDeleted.count
    user  = User.new

    user.deleted = true

    assert_equal true, user.deleted
    assert_equal count, UserDeleted.count
  end

  def test_default
    user  = User.new
    assert_equal false, user.deleted
  end

  def test_save
    count = UserDeleted.count
    user  = User.new

    user.deleted = true
    user.save

    assert_equal true, user.deleted
    assert_equal count+1, UserDeleted.count
  end

  def test_create
    count = UserDeleted.count
    user  = User.create!(:deleted=>true)

    assert_equal true, user.deleted
    assert_equal count+1, UserDeleted.count
  end
end


