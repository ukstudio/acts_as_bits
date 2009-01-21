require File.dirname(__FILE__) + '/test_helper'

class ActsAsBitsTest < Test::Unit::TestCase
  fixtures :mixins

  def test_respond
    m = mixins(:bits_00)

    assert_respond_to m, :admin
    assert_respond_to m, :admin?
    assert_respond_to m, :admin=

    assert_respond_to m, :composer
    assert_respond_to m, :composer?
    assert_respond_to m, :composer=
  end

  def test_reader_00
    m = mixins(:bits_00)

    assert ! m.admin?
    assert ! m.composer?
  end

  def test_writer_01
    m = mixins(:bits_01)

    m.admin = true
    m.composer = false

    # save?

    assert m.admin?
    assert ! m.composer?
  end

  def test_reader_to_new_object
    m = Mixin.new

    assert_equal false, m.admin?
    assert_equal false, m.composer?
  end

  def test_names
    assert_equal %w( top right bottom left ), Mixin.position_names
  end

  def test_labels
    assert_equal "TOP",    Mixin.top_label
    assert_equal "RIGHT",  Mixin.right_label
    assert_equal "BOTTOM", Mixin.bottom_label
    assert_equal "LEFT",   Mixin.left_label

    assert_equal %w( TOP RIGHT BOTTOM LEFT ), Mixin.position_labels
  end

  def test_names_with_labels
    expected = [
                [:top,    "TOP"],
                [:right,  "RIGHT"],
                [:bottom, "BOTTOM"],
                [:left,   "LEFT"],
               ]
    assert_equal expected, Mixin.position_names_with_labels
  end

  def test_nil_means_blank_column
    assert_equal %w( flag1 flag3 ), Mixin.blank_flag_names

    assert_equal false, mixins(:bits_00).flag1
    assert_equal false, mixins(:bits_00).flag3
    assert_equal true , mixins(:bits_10).flag1
    assert_equal false, mixins(:bits_10).flag3

    assert_equal "0000",  Mixin.new.positions

    assert_equal "00",  Mixin.new.blank_flags
    assert_equal false, Mixin.new.flag1
    assert_equal false, Mixin.new.flag3
  end

  def test_referer_to_out_of_index
    Mixin.delete_all
    mixin = Mixin.create!(:positions=>"11")
    assert_equal true,  mixin.top?
    assert_equal true,  mixin.right?
    assert_equal false, mixin.bottom?
    assert_equal false, mixin.left?
  end

  def test_subscribe_to_out_of_index
    Mixin.delete_all
    mixin = Mixin.create!(:positions=>"11")

    assert_nothing_raised do
      mixin.left = true
    end

    assert_equal true, mixin.left?
  end

  def test_functional_accessor
    mixin = Mixin.create!(:positions=>"1010")
    assert_equal true,  mixin.position?(:top)
    assert_equal false, mixin.position?(:right)
    assert_equal true,  mixin.position?(:bottom)
    assert_equal false, mixin.position?(:left)
  end

  def test_functional_accessor_without_args
    mixin = Mixin.create!(:positions=>"0001")
    assert_equal true,  mixin.position?

    mixin = Mixin.create!(:positions=>"0000")
    assert_equal false, mixin.position?

    mixin = Mixin.create!(:positions=>"1111")
    assert_equal true,  mixin.position?
  end

  def test_sanitize_sql_hash
    expected = ["COALESCE(SUBSTRING(mixins.positions,1,1),'') = '1'", "COALESCE(SUBSTRING(mixins.positions,4,1),'') <> '1'"]
    executed = Mixin.__send__(:sanitize_sql_hash, {:top => true, :left => false})
    executed = executed.delete('`"').split(/ AND /).sort

    assert_equal expected, executed
  end

  def test_search
    conditions = {:top=>true}
    assert_equal 1, Mixin.count(:conditions=>conditions)
    assert_equal 1, Mixin.find(:all, :conditions=>conditions).size

    conditions = {:top=>false, :right=>false, :bottom=>false, :left=>false}
    assert_equal 2, Mixin.count(:conditions=>conditions)
    assert_equal 2, Mixin.find(:all, :conditions=>conditions).size

    conditions = {:top=>true, :right=>true, :bottom=>true, :left=>true}
    assert_equal 1, Mixin.count(:conditions=>conditions)
    assert_equal 1, Mixin.find(:all, :conditions=>conditions).size
  end

  def test_set_all
    obj = Mixin.new
    assert_equal "00", obj.flags

    obj.flags = true
    assert_equal "11", obj.flags

    obj.flags = false
    assert_equal "00", obj.flags
  end
end
