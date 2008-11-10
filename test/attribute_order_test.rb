require File.dirname(__FILE__) + "/test_helper"

class AttributeOrderTest < Test::Unit::TestCase
  def setup
    Object.__send__ :remove_const, "Member" if defined?(Member)
    Object.const_set "Member", Class.new(ActiveSeven::Base)
  end

  def test_order1
    Member.has :name, :string
    Member.has :age,  :integer
    Member.has :birthday, :date

    assert_equal [:name, :age, :birthday], Member.attributes.keys
  end

  def test_order2
    Member.has :address, :string
    Member.has :birthday, :date
    Member.has :age,  :integer
    Member.has :name, :string

    assert_equal [:address, :birthday, :age, :name], Member.attributes.keys
  end
end
