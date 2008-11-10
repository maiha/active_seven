require File.dirname(__FILE__) + '/test_helper'

class NamedOptionsTest < Test::Unit::TestCase
  def user(*args)
    NamedOptions.new(args, :name, :age)
  end

  def expected
    HashWithIndifferentAccess.new("name"=>"maiha", "age"=>14)
  end

  def expected_only_name
    HashWithIndifferentAccess.new("name"=>"maiha")
  end

  def test_set_one_value_by_hash
    assert_equal expected_only_name, user(:name=>"maiha")
  end

  def test_set_plural_values_by_hash
    assert_equal expected, user(:name=>'maiha', :age=>14)
  end

  def test_set_one_value_by_position
    assert_equal expected_only_name, user("maiha")
  end

  def test_set_plural_values_by_position
    assert_equal expected, user('maiha', 14)
  end

  def test_set_plural_values_by_position_with_overflow
    assert_raises(IndexError) do
      user('maiha', 14, :foo)
    end
  end

  def test_set_plural_values_by_composite_args
    assert_equal expected, user('maiha', :age=>14)
  end

  def test_real_arg_overwrites_hash
    options = {:name=>'kuma', :age=>14}
    assert_equal expected, user('maiha', options)

    options = {:name=>'kuma', :age=>13}
    assert_equal expected, user('maiha', 14, options)
  end

  def test_named_accessor
    options = user('maiha', 14)
    assert_equal "maiha", options.name
    assert_equal 14,      options.age
  end

  def test_nil_equal
    options = user
    options[:name] ||= "maiha"
    assert_equal "maiha", options.name
  end

  def test_named_values
    options = user('maiha', 14, :dummy=>true)
    assert_equal ["maiha", 14], options.named_values
  end

  def test_treat_hash_as_default_values
    args = ["maiha", 14]
    options = NamedOptions.new(args, :name, :age, :group=>"Berryz")

    assert_equal "maiha",  options.name
    assert_equal 14,       options.age
    assert_equal "Berryz", options.group
  end

  def test_default_values_are_overwritten_by_args
    args = ["maiha", 14, {:group=>"neet"}]
    options = NamedOptions.new(args, :name, :age, :group=>"Berryz")

    assert_equal "maiha",  options.name
    assert_equal 14,       options.age
    assert_equal "neet",   options.group
  end
end

