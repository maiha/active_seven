require File.dirname(__FILE__) + "/test_helper"

class EntityTest < Test::Unit::TestCase
  models :monster

  def test_attributes
    expected = %w( kind level name )
    assert_equal expected, Monster.attributes.keys.map(&:to_s).sort
  end

  def test_column
    # normal attribute
    assert_equal Fixnum, Monster.new.column_for_attribute(:id).klass

    # proxy attribute
    assert_equal String, Monster.new.column_for_attribute(:name).klass
  end
end
