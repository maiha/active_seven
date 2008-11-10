require File.dirname(__FILE__) + "/test_helper"

class StatusTest < Test::Unit::TestCase
  models :monster

  def setup
#    Monster.find(:all).each(&:destroy)
  end

  def quoted_kind
    quote_column_name("kind")
  end

public
  def test_entity_query
    Monster.create!(:name=>"maiha", :kind=>"human")
    human_kind = Monster.kind("human")

    expected = "SELECT DISTINCT monster_id FROM monster_kinds WHERE ( #{quoted_kind} = 'human' )"
    assert_equal expected, human_kind.entity_query
  end

  def test_join_query
    Monster.create!(:name=>"maiha", :kind=>"human")
    human_kind = Monster.kind("human")

    expected = "INNER JOIN ( SELECT DISTINCT monster_id FROM monster_kinds WHERE ( #{quoted_kind} = 'human' ) ) AS monster_kinds_entity"
    assert_equal expected, human_kind.join_query
  end

  def test_condition_hit
    Monster.create!(:name=>"maiha", :kind=>"human")
    human_kind = Monster.kind("human")

    monsters = (Monster & human_kind).find(:all)
    assert_equal 1, monsters.size
    assert_equal 1, (Monster & human_kind).count
  end

  def test_condition_miss
    Monster.create!(:name=>"maiha", :kind=>"human")
    dragon_kind = Monster.kind("dragon")

    monsters = (Monster & dragon_kind).find(:all)
    assert_equal 0, monsters.size
    assert_equal 0, (Monster & dragon_kind).count
  end

  def test_statused_find_returns_instances_of_base_class
    Monster.create!(:name=>"maiha", :kind=>"human")
    assert_equal Monster, Monster.kind("human").find(:first).class
  end

  def test_eager_loading_with_status_attribute
    Monster.create!(:name=>"maiha", :kind=>"human")

    maiha = nil
    assert_nothing_raised do
      maiha = Monster.find(:first, :include=>"kind")
    end

    MonsterKind.delete_all
    assert_equal "human", maiha.kind
  end

end
