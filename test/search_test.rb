# -*- coding:utf-8-unix -*-

require File.dirname(__FILE__) + "/test_helper"

class SearchTest < Test::Unit::TestCase
protected
  def setup
    Monster.find(:all).each(&:destroy)
    Monster.create!(:names=>["dragon", "dracky"], :level=>20)
  end

public
  def test_condition_ok
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon"

    monsters = (Monster & where).find(:all, :include=>:name)
    assert_equal 1, monsters.size
    assert_equal ["dragon", "dracky"], monsters.first.names
  end

  def test_condition_ng
    where = ActiveSeven::Where.new(MonsterName)
    where.equal "dragon2"

    monsters = (Monster & where).find(:all, :include=>:name)
    assert_equal 0, monsters.size
  end
end
