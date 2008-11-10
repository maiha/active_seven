# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + "/test_helper"

class WhereTest < Test::Unit::TestCase
  models :monster

protected
  def setup
    Monster.find(:all).each(&:destroy)
    Monster.create!(:names=>["dragon", "slime"], :level=>20)
  end

  def quoted_name
    quote_column_name("name")
  end

public

  def test_condition_in_eagar_loading
    options = {
      :include    => [:name, :level],
      :conditions => ["name = ?", "dragon"],
    }
    monsters = Monster.find(:all, options)
    MonsterName.delete_all
    assert_equal 1, monsters.size
  end

  def test_condition_in_eagar_loading_with_buggy_case
    options = {
      :include    => [:name, :level],
      :conditions => ["name = ?", "dragon"],
    }
    monsters = Monster.find(:all, options)
    dragon = monsters.first

    # 名前を複数もつ状況で検索すると
    # 結果セットにはヒットした方の名前しか入らない
    # (本当は2になるべきだが、eager loading の副作用)
    MonsterName.delete_all
    assert_equal 1, dragon.names.size

    # よって、存在の集合演算(INNER JOIN) と 結果セットに分離する
    # → test_condition_in_eager_loading_with_where_method
  end


  # Base.connection.quote_column_name(column_name) がDB依存なので
  # quoted_name を利用する

  def test_add_condition_equal
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"

    expected = ["( #{quoted_name} = ? )", "dragon"]
    assert_equal expected, where.generate
  end

  def test_where_method_with_symbol
    where = Monster.where :name
    where.equal "dragon"

    expected = ["( #{quoted_name} = ? )", "dragon"]
    assert_equal expected, where.generate
  end

  def test_where_method_with_string
    where = Monster.where "name"
    where.equal "dragon"

    expected = ["( #{quoted_name} = ? )", "dragon"]
    assert_equal expected, where.generate
  end

  def test_add_condition_by_statement
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"

    expected = ["( #{quoted_name} = ? )", "dragon"]
    assert_equal expected, where.generate
  end

  def test_entity_query
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"

    expected = "SELECT DISTINCT monster_id FROM monster_names WHERE ( #{quoted_name} = 'dragon' )"
    assert_equal expected, where.entity_query
  end

  def test_entity_query_not
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"
    where = where.not

    expected = "SELECT DISTINCT monster_id FROM monster_names WHERE NOT ( #{quoted_name} = 'dragon' )"
    assert_equal expected, where.entity_query
  end

  def test_join_query
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"

    expected = "INNER JOIN ( SELECT DISTINCT monster_id FROM monster_names WHERE ( #{quoted_name} = 'dragon' ) ) AS monster_names_entity"
    assert_equal expected, where.join_query
  end

  def test_join_query_not
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"
    where = where.not

    expected = "INNER JOIN ( SELECT DISTINCT monster_id FROM monster_names WHERE NOT ( #{quoted_name} = 'dragon' ) ) AS monster_names_entity"
    assert_equal expected, where.join_query
  end

  ######################################################################
  ### Where Methods

  def test_where_with_one_element_hash
    dragons = Monster.where :name => "dragon"
    assert_equal ActiveSeven::Where, dragons.class
  end

  def test_condition_with_where_method
    dragons = Monster.where :name => "dragon"
    assert_equal 1, (Monster & dragons).count
  end

  def test_condition_in_eager_loading_with_where_method
    options = {
      :include => [:name, :level],
    }
    dragons = Monster.where :name => "dragon"
    dragon  = (Monster & dragons).find(:first, options)

    MonsterName.delete_all
    assert_equal 2, dragon.names.size
  end

  def test_condition_in_eagar_loading_with_where_option
    options = {
      :include => [:name, :level],
      :where   => {:name => 'dragon' },
    }
#    monsters = Monster.where :name =>

#     monsters = Monster.find(:all, options)
#     dragon = monsters.first
#     assert_equal 2, dragon.names.size
  end

  def test_not_query
    # recreate dragon so that original data has plural names
    Monster.delete_all
    Monster.create! :name=>"dragon"

    dragons = Monster.where :name => "dragon"
    non_dragons = dragons.not;

    Monster.create! :name=>"nksk"
    Monster.create! :name=>"maiha"

    # now "dragon", "nksk", "maiha" exist

    assert_equal 1, dragons.count
    assert_equal 2, non_dragons.count
    assert_equal 3, Monster.count
  end

  def test_tautology_about_not
    # recreate dragon so that original data has plural names
    Monster.delete_all
    Monster.create! :name=>"dragon"

    dragons = Monster.where :name => "dragon"
    non_dragons = dragons.not;

    assert_equal 0, (dragons & non_dragons).count
  end

  def test_double_negation_means_self
    dragons = Monster.where :name => "dragon"
    assert_equal dragons.__id__, dragons.not.not.__id__
  end

  def test_going_negative_flush_caches
    # recreate dragon so that original data has plural names
    Monster.delete_all
    Monster.create! :name=>"dragon"
    Monster.create! :name=>"nksk"
    Monster.create! :name=>"maiha"

    dragons = Monster.where :name => "dragon"
    assert_equal 1, dragons.count
    assert_equal 2, dragons.not.count
    assert_equal %w( dragon ), dragons.find(:all).map(&:name).flatten
    assert_equal %w( maiha nksk ), dragons.not.find(:all).map(&:name).flatten.sort
  end

end
