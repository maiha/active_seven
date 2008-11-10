require File.dirname(__FILE__) + "/test_helper"

class AttributeTest < Test::Unit::TestCase
  models :monster

  def test_has_one_reader_to_singular_value
    one = Monster.find 1
    assert_equal nil,   one.name
  end

  def test_has_one_setter_to_singular_value
    one = Monster.find 1
    one.name = "dragon"
    assert_equal "dragon",   one.name
  end

  def test_has_one_setter_writes_nothing_before_save
    MonsterName.delete_all
    one = Monster.find 1
    one.name = "dragon"
    assert_equal 0, MonsterName.count
  end

  def test_has_one_setter_writes_associations
    MonsterName.delete_all
    one = Monster.find 1
    one.name = "dragon"
    one.save
    assert_equal 1, MonsterName.count
    assert_equal %w( dragon ), MonsterName.find(:all).map(&:name)
  end

  def test_has_one_setter_writes_plural_values_with_specified_order
    MonsterName.delete_all
    one = Monster.find 1
    one.names = %w( dragon magician )
    one.save
    assert_equal 2, MonsterName.count
    assert_equal %w( dragon magician ), MonsterName.find(:all, :order=>"pos").map(&:name)
    assert_equal %w( dragon magician ), one.names
    assert_equal %w( dragon magician ), one.monster_names.map(&:name)

    MonsterName.delete_all
    one = Monster.find 1
    one.names = %w( magician dragon )
    one.save
    assert_equal 2, MonsterName.count
    assert_equal %w( magician dragon ), MonsterName.find(:all, :order=>"pos").map(&:name)
    assert_equal %w( magician dragon ), one.names
    assert_equal %w( magician dragon ), one.monster_names.map(&:name)
  end


  def test_attributes_are_linked_for_deletion
    all_count = MonsterName.count
    one       = Monster.find 1
    one_count = one.names.size

    one.destroy
    assert_equal all_count - one_count, MonsterName.count
  end

  def test_resolve_association_name_automatically_on_eager_loading
    assert_nothing_raised do
      Monster.find(1, :include=>:name)
      Monster.find(1, :include=>:names)
      Monster.find(1, :include=>:monster_names)
    end
  end

  def test_attributes_have_belongs_to_feature
    data = Monster.create! :name=>"nksk"

    nksk = Monster.find(data.id)
    name = nksk.monster_names.first

    assert_equal data.id, name.monster.id
  end
end
