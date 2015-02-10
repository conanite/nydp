require 'spec_helper'

describe Nydp::Parser do
  let(:aa)               { Nydp::Symbol.mk :aa,                   ns }
  let(:a)                { Nydp::Symbol.mk :a,                    ns }
  let(:b)                { Nydp::Symbol.mk :b,                    ns }
  let(:c)                { Nydp::Symbol.mk :c,                    ns }
  let(:d)                { Nydp::Symbol.mk :d,                    ns }
  let(:zz)               { Nydp::Symbol.mk :zz,                   ns }
  let(:foo)              { Nydp::Symbol.mk :foo,                  ns }
  let(:bar)              { Nydp::Symbol.mk :bar,                  ns }
  let(:zab)              { Nydp::Symbol.mk :zab,                  ns }
  let(:quote)            { Nydp::Symbol.mk :quote,                ns }
  let(:quasiquote)       { Nydp::Symbol.mk :quasiquote,           ns }
  let(:unquote)          { Nydp::Symbol.mk :unquote,              ns }
  let(:unquote_splicing) { Nydp::Symbol.mk :"unquote-splicing",   ns }
  let(:comment)          { Nydp::Symbol.mk :comment,              ns }
  let(:dotsyn)           { Nydp::Symbol.mk :"dot-syntax",         ns }
  let(:cocosyn)          { Nydp::Symbol.mk :"colon-colon-syntax", ns }
  let(:colosyn)          { Nydp::Symbol.mk :"colon-syntax",       ns }

  it "should return a stream of tokens" do
    t = Nydp::Tokeniser.new ""
    expect(t.next_token).to eq nil
  end

  it "should return another stream of tokens" do
    t = Nydp::Tokeniser.new "(a b c 1 2 3)"
    tt = []
    tok = t.next_token
    while tok
      tt << tok
      tok = t.next_token
    end
    expect(tt).to eq [[:left_paren, ""], [:symbol, "a"], [:symbol, "b"], [:symbol, "c"], [:number, 1.0], [:number, 2.0], [:number, 3.0], [:right_paren]]
  end

  it "should parse an empty expression" do
    expect(parse "").to be_nil
  end

  it "should parse an empty expression" do
    expect(parse "()").to eq Nydp.NIL
  end

  it "should parse a lisp expression" do
    expect(parse "(foo bar)").to eq pair_list([foo, bar])
  end

  it "should parse numbers expression" do
    expect(parse "(1 2 3)").to eq pair_list([1, 2, 3])
  end

  it "should parse an improper list" do
    expect(parse "(1 2 3 . 4)").to eq pair_list([1, 2, 3], 4)
  end

  it "should parse a string" do
    s1 = sym 'string-pieces'
    s2 = Nydp::StringFragmentCloseToken.new "hello there", '"hello there"'

    x1 = 1
    x2 = "hello there"
    x3 = 3

    expected = pair_list [x1, x2, x3]

    expect(parse '(1 "hello there" 3)').to eq expected
  end

  it "should parse a string" do
    x1 = sym 'join'
    x2 = " - "
    x3 = 1
    x4 = 2
    x5 = 3

    expected = pair_list [x1, x2, x3, x4, x5]

    expect(parse '(join " - " 1 2 3)').to eq expected
  end

  it "should not get confused by embedded lisp in a string" do
    s1 = sym 'string-pieces'
    s2 = Nydp::StringFragmentCloseToken.new "hello (1 2 3) there", '"hello (1 2 3) there"'

    x1 = 1
    x2 = "hello (1 2 3) there"
    x3 = 3

    expected = pair_list [x1, x2, x3]

    expect(parse '(1 "hello (1 2 3) there" 3)').to eq expected
  end

  it "should handle escaped quotes inside a string" do
    s1 = sym 'string-pieces'
    s2 = Nydp::StringFragmentCloseToken.new "hello there \"jimmy\"", '"hello there \"jimmy\""'

    x1 = 1
    x2 = "hello there \"jimmy\""
    x3 = 3

    expected = pair_list [x1, x2, x3]

    expect(parse '(1 "hello there \"jimmy\"" 3)').to eq expected
  end

  it "should handle escaped tabs and newlines inside a string" do
    expected = Nydp::StringAtom.new "hello\tworld\nnice day"
    parsed = parse "\"hello\\tworld\\nnice day\""
    expect(parsed).to eq expected
  end

  it "should parse a plain symbol" do
    expect(parse "foo").to eq foo
  end

  it "should parse a dotted symbol" do
    expect(parse "foo.bar").to eq  pair_list([dotsyn, foo, bar])
  end

  it "should parse a dotted symbol" do
    expect(parse "(list a b foo.bar c)").to eq  pair_list([sym(:list), a, b, pair_list([dotsyn, foo, bar]), c])
  end

  it "should parse a colon-colon symbol" do
    expect(parse "foo::bar").to eq  pair_list([cocosyn, foo, bar])
  end

  it "should parse a colon-symbol within a colon-colon within a dotted symbol" do
    expect(parse "aa.foo:foo::bar:bar.zz").to eq pair_list([dotsyn, aa, pair_list([cocosyn, pair_list([colosyn, foo, foo]), pair_list([colosyn, bar, bar])]), zz])
  end

  it "should quote symbols" do
    expect(parse "'foo").to eq pair_list([quote, foo])
  end

  it "should quote-unquote symbols" do
    expect(parse "',foo").to eq pair_list([quote, pair_list([unquote, foo])])
  end

  it "should quote lists" do
    expect(parse "'(foo)").to eq pair_list([quote, pair_list([foo])])
  end

  it "should unquote atoms" do
    expect(parse ",foo").to eq pair_list([unquote, foo])
  end

  it "should unquote lists" do
    expect(parse ",(bar)").to eq pair_list([unquote, pair_list([bar])])
  end

  it "should unquote-splicing atoms" do
    expect(parse ",@foo").to eq pair_list([unquote_splicing, foo])
  end

  it "should unquote-splicing lists" do
    expect(parse ",@(bar)").to eq pair_list([unquote_splicing, pair_list([bar])])
  end

  it "should quasiquote atoms" do
    expect(parse "`foo").to eq pair_list([quasiquote, foo])
  end

  it "should quasiquote lists" do
    expect(parse "`(bar)").to eq pair_list([quasiquote, pair_list([bar])])
  end

  it "should parse nested lists" do
    expect(parse "(a b (c) d)").to eq pair_list([a, b, pair_list([c]), d])
  end

  it "should even parse comments" do
    txt = "(def foo (bar)
  ; here's a comment
  (zab))
"
    c1 = pair_list([comment, "here's a comment"])
    fbar = pair_list([bar])
    fzab = pair_list([Nydp::Symbol.mk(:zab, ns)])
    fdef = Nydp::Symbol.mk(:def, ns)
    expr = pair_list([fdef, foo, fbar, c1, fzab])
    expect(parse txt).to eq expr
  end
end
