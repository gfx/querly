require_relative "test_helper"

class PatternParserTest < Minitest::Test
  include TestHelper

  def test_parser1
    pattern = parse_expr("foo().bar")

    assert_instance_of E::Send, pattern
    assert_equal :bar, pattern.name
    assert_instance_of A::AnySeq, pattern.args

    assert_instance_of E::Send, pattern.receiver
    assert_equal :foo, pattern.receiver.name
    assert_nil pattern.receiver.args
  end

  def test_aaa
    # p Querly::Pattern::Parser.parse("foo(!foo: bar)")
  end

  def test_ivar
    pat = parse_expr("@")
    assert_equal E::Ivar.new(name: nil), pat
  end

  def test_ivar_with_name
    pat = parse_expr("@x_123A")
    assert_equal E::Ivar.new(name: :@x_123A), pat
  end

  def test_pattern
    pat = parse_expr(":racc")
    assert_equal E::Literal.new(type: :symbol, value: :racc), pat
  end

  def test_constant
    pat = parse_expr("E")
    assert_equal E::Constant.new(path: [:E]), pat
  end

  def test_keyword_arg
    pat = parse_expr("foo(!x: 1, ...)")
    assert_equal E::Send.new(receiver: E::Any.new,
                             name: :foo,
                             args: A::KeyValue.new(key: :x,
                                                   value: E::Literal.new(type: :int, value: 1),
                                                   negated: true,
                                                   tail: A::AnySeq.new)), pat
  end

  def test_keyword_arg2
    pat = parse_expr("foo(!X: 1, ...)")
    assert_equal E::Send.new(receiver: E::Any.new,
                             name: :foo,
                             args: A::KeyValue.new(key: :X,
                                                   value: E::Literal.new(type: :int, value: 1),
                                                   negated: true,
                                                   tail: A::AnySeq.new)), pat
  end

  def test_method_names
    assert_equal :[], parse_expr("[]()").name
    assert_equal :[]=, parse_expr("[]=()").name
    assert_equal :!, parse_expr("!()").name
  end

  def test_send
    assert_equal :f, parse_expr("f").name
    assert_equal :f, parse_expr("f()").name
    assert_equal :f, parse_expr("_.f").name
    assert_equal :f, parse_expr("_.f()").name
    assert_equal :F, parse_expr("F()").name
    assert_equal :F, parse_expr("_.F()").name
    assert_equal :F, parse_expr("_.F").name
  end

  def test_method_name
    assert_equal :f!, parse_expr("f!()").name
    assert_equal :f=, parse_expr("f=(3)").name
    assert_equal :f?, parse_expr("f?()").name
  end

  def test_block_pass
    pat = parse_expr("map(&:id)")
    args = pat.args

    assert_instance_of A::BlockPass, args
    assert_equal E::Literal.new(type: :symbol, value: :id), args.expr
  end

  def test_vcall
    pat = parse_expr("foo")

    assert_instance_of E::Vcall, pat
    assert_equal :foo, pat.name
  end

  def test_dstr
    pat = parse_expr(":dstr:")
    assert_instance_of E::Dstr, pat
  end

  def test_any_kinded
    pat = parse_kinded("foo")
    assert_instance_of K::Any, pat
  end

  def test_conditonal_kinded
    pat = parse_kinded("foo [conditional]")
    assert_instance_of K::Conditional, pat
    refute pat.negated
  end

  def test_conditional_kinded2
    pat = parse_kinded("foo [!conditional]")
    assert_instance_of K::Conditional, pat
    assert pat.negated
  end

  def test_discarded_kinded
    pat = parse_kinded("foo [discarded]")
    assert_instance_of K::Discarded, pat
    refute pat.negated
  end

  def test_discarded_kinded2
    pat = parse_kinded("foo [!discarded]")
    assert_instance_of K::Discarded, pat
    assert pat.negated
  end
end
