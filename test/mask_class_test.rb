require File.dirname(__FILE__) + "/test_helper"

class MaskClassTest < Test::Unit::TestCase
  models :user

  def setup
    User.find(:all).each(&:destroy)
  end

public
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


class MaskClassFeatureTest < Test::Unit::TestCase
  models :user

protected
  def setup
    User.find(:all).each(&:destroy)
    User.create!(:name=>"maiha",  :deleted=>true)
    User.create!(:name=>"momoko", :deleted=>false)
  end

  def quoted_deleted
    quote_column_name("deleted")
  end

public
  def test_mask_is_mask
    assert User.deleted.is_a?(ActiveSeven::Mask)
  end

  def test_real_table_name
    assert_equal "user_deleteds", User.deleted.real_table_name
  end

  def test_join_query
    expected = "INNER JOIN ( SELECT DISTINCT user_id FROM user_deleteds WHERE ( #{quoted_deleted} = #{quote(true)} ) ) AS user_deleteds_entity"
    assert_equal expected, User.deleted.join_query
  end

  def test_join_query_with_alias
    expected = "INNER JOIN ( SELECT DISTINCT user_id FROM user_deleteds WHERE ( #{quoted_deleted} = #{quote(true)} ) ) AS t1"
    assert_equal expected, User.deleted.join_query("t1")
  end

  def test_table_name
    expected = "user_deleteds"
    assert_equal expected, User.deleted.table_name
  end

  def test_masked_count
    assert_equal 1, User.deleted.count
  end

  def test_masked_find_all
    assert_equal %w( maiha momoko ),  User.find(:all, :order=>"id").map(&:name)
    assert_equal %w( maiha ), User.deleted.find(:all, :order=>"id").map(&:name)
  end

  def test_no_topples_mean_default_value
    assert_equal 1, User.deleted.count

    User.create!(:name=>"kuma")
    assert_equal 1, User.deleted.count
  end

  def test_masked_find_returns_instances_of_base_class
    assert_equal User, User.deleted.find(:first).class
  end

end

