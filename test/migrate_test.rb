require File.dirname(__FILE__) + "/test_helper"

class MigrateTest < Test::Unit::TestCase
  class Nacky < ActiveSeven::Base
    has :name, :string
  end

  class Nksk < ActiveSeven::Base
    has :name, :string
    has :age,  :integer
  end

public
  def test_detect_rest_tables
    # 1st migration
    Nacky.migrate

    # add a new attribute
    Nacky.has :smile, :column=>:string

    # 2nd migration
    Nacky.migrate

    assert_nothing_raised do
      NackySmile.count
    end
  end

  def test_ordered_args
    assert_nothing_raised do
      Nksk.migrate
    end

    assert_equal :string,  NkskName.column.type
    assert_equal :integer, NkskAge.column.type
  end
end
