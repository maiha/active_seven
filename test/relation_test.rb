require File.dirname(__FILE__) + "/test_helper"

class RelationTest < Test::Unit::TestCase
  models :monster, :area

public
  ######################################################################
  ### Relational Operations

  def test_create_relation
    r = Monster * Area
    assert_equal ActiveSeven::Relation, r.class
  end

  def test_sorted_table_name
    assert_equal "areas_monsters", (Monster * Area).table_name
    assert_equal "areas_monsters", (Area * Monster).table_name
  end

  def test_migrate
    r = Monster * Area
    assert_nothing_raised do
      r.migrate :down
      r.migrate
    end
  end

  def test_migrate_without_valid_classes
    assert_raises(TypeError) do
      Monster * ActiveSeven::Where.new(Monster)
    end
  end
end
