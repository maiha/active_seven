require File.dirname(__FILE__) + "/test_helper"

class AttributePluralizeTest < Test::Unit::TestCase

  def setup
    @force_pluralize_backup = ActiveSeven::Base.force_pluralize
    Object.__send__ :remove_const, "Song" if defined?(Song)
    Object.const_set "Song", Class.new(ActiveSeven::Base)
  end

  def teardown
    ActiveSeven::Base.force_pluralize = @force_pluralize_backup or
      raise '@force_pluralize_backup is missing' 
  end

  def test_force_pluralize_forces_pluralize
    ActiveSeven::Base.force_pluralize = true
    Song.has :lyrics, :string
    assert_equal [:song_lyricss], Song.reflections.keys
  end

  def test_force_pluralize_raises_exception
    ActiveSeven::Base.force_pluralize = false
    assert_raises(ActiveSeven::CannotPluralize) do
      Song.has :lyrics, :string
    end
  end
end
