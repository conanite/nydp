require 'spec_helper'

describe Nydp::Parser do
  let(:empty)            { Nydp::Symbol.mk :"",                   ns }
  let(:aa)               { Nydp::Symbol.mk :aa,                   ns }
  let(:a)                { Nydp::Symbol.mk :a,                    ns }
  let(:b)                { Nydp::Symbol.mk :b,                    ns }
  let(:c)                { Nydp::Symbol.mk :c,                    ns }
  let(:d)                { Nydp::Symbol.mk :d,                    ns }
  let(:zz)               { Nydp::Symbol.mk :zz,                   ns }
  let(:foo)              { Nydp::Symbol.mk :foo,                  ns }
  let(:bar)              { Nydp::Symbol.mk :bar,                  ns }
  let(:foobar)           { Nydp::Symbol.mk :foobar,               ns }
  let(:zab)              { Nydp::Symbol.mk :zab,                  ns }
  let(:quote)            { Nydp::Symbol.mk :quote,                ns }
  let(:quasiquote)       { Nydp::Symbol.mk :quasiquote,           ns }
  let(:unquote)          { Nydp::Symbol.mk :unquote,              ns }
  let(:prefix_list)      { Nydp::Symbol.mk :"prefix-list",        ns }
  let(:unquote_splicing) { Nydp::Symbol.mk :"unquote-splicing",   ns }
  let(:comment)          { Nydp::Symbol.mk :comment,              ns }
  let(:dotsyn)           { Nydp::Symbol.mk :"dot-syntax",         ns }
  let(:cocosyn)          { Nydp::Symbol.mk :"colon-colon-syntax", ns }
  let(:colosyn)          { Nydp::Symbol.mk :"colon-syntax",       ns }
  let(:atsyn)            { Nydp::Symbol.mk :"at-syntax",          ns }
  let(:string_pieces)    { Nydp::Symbol.mk :"string-pieces",      ns }

  it "should return a stream of tokens" do
    reader = Nydp::StringReader.new ""
    t = Nydp.new_tokeniser reader
    expect(t.next_token).to eq nil
  end

  it "should parse an empty expression" do
    expect(parse "").to be_nil
  end

  it "should parse an empty expression" do
    expect(parse "()").to eq Nydp::NIL
  end

  it "should parse a lisp expression" do
    expect(parse "(foo bar)").to eq pair_list([foo, bar])
  end

  it "should parse untidy symbols" do
    s0 = sym "foo bar"
    s1 = sym ""
    s2 = sym '" hello, there, silly billy!"'
    expect(parse "(|foo bar| || |\" hello, there, silly billy!\"|)").to eq pair_list([s0, s1, s2])
  end

  it "should parse untidy symbols with special syntax" do
    quote_foo_bar = parse "'|foo bar|"
    expect(quote_foo_bar).to eq pair_list([quote, sym("foo bar")])
  end

  it "should parse empty symbol with special syntax" do
    quote_empty = parse "'||"
    expect(quote_empty).to eq pair_list([quote, sym("")])
  end

  it "should parse numbers expression" do
    expect(parse "(1 2 3)").to eq pair_list([1, 2, 3])
  end

  it "should parse an improper list" do
    expect(parse "(1 2 3 . 4)").to eq pair_list([1, 2, 3], 4)
  end

  it "should parse an improper list containing symbols" do
    expect(parse "(foo foo . bar)").to eq pair_list([foo, foo], bar)
  end

  it "should parse a string" do
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
    s2 = Nydp::StringFragmentCloseToken.new "hello (1 2 3) there", '"hello (1 2 3) there"'

    x1 = 1
    x2 = "hello (1 2 3) there"
    x3 = 3

    expected = pair_list [x1, x2, x3]

    expect(parse '(1 "hello (1 2 3) there" 3)').to eq expected
  end

  it "should handle escaped quotes inside a string" do
    s2 = Nydp::StringFragmentCloseToken.new "hello there \"jimmy\"", '"hello there \"jimmy\""'

    x1 = 1
    x2 = "hello there \"jimmy\""
    x3 = 3

    expected = pair_list [x1, x2, x3]

    expect(parse '(1 "hello there \"jimmy\"" 3)').to eq expected
  end

  it "should handle escaped tabs and newlines inside a string" do
    expected = "hello\tworld\nnice day"
    parsed = parse "\"hello\\tworld\\nnice day\""
    expect(parsed).to eq expected
  end

  it "should parse a brace list" do
    expect(parse "{a b c d}").to eq pair_list [sym("brace-list"), a, b, c, d]
  end

  it "should parse a plain symbol" do
    expect(parse "foo").to eq foo
  end

  it "should parse a dotted symbol" do
    expect(parse "foo.bar").to eq  pair_list([dotsyn, foo, bar])
  end

  it "should spot numbers hiding in special syntax" do
    parsed = parse("foo.2:3:4")
    expect(parsed.inspect).to eq "(colon-syntax (dot-syntax foo 2) 3 4)"

    expect(parsed.map &:class).to eq [Nydp::Symbol, Nydp::Pair, Fixnum, Fixnum]
    expect(parsed.cdr.car.map &:class).to eq [Nydp::Symbol, Nydp::Symbol, Fixnum]
  end

  it "should handle prefix and postfix syntax also" do
    parsed = parse(".foo123:")
    expect(parsed.inspect).to eq "(colon-syntax (dot-syntax || foo123) ||)"
  end

  it "should parse a dotted symbol" do
    expected = parse "(list a b (dot-syntax foo bar) c)"
    expect(parse "(list a b foo.bar c)").to eq expected
  end

  it "should parse a colon-colon symbol" do
    expect(parse "foo::bar").to eq  pair_list([cocosyn, foo, bar])
  end

  it "should parse an at symbol" do
    expect(parse "foo@bar").to eq  pair_list([atsyn, foo, bar])
  end

  it "should parse a prefix-at symbol" do
    expect(parse "@foobar").to eq  pair_list([atsyn, empty, foobar])
  end

  it "should parse a colon-symbol within a colon-colon within a dotted symbol" do
    expected = parse "(colon-colon-syntax (colon-syntax (dot-syntax aa foo) foo) (colon-syntax bar (dot-syntax bar zz)))"
    expect(parse "aa.foo:foo::bar:bar.zz").to eq expected
  end

  it "should quote symbols" do
    expect(parse "'foo").to eq pair_list([quote, foo])
  end

  it "should not let quote decorations trick it into thinking numbers are symbols" do
    two = parse("'2").cdr.car
    expect(two.class).to eq 2.class
    expect(two).to eq 2
  end

  it "should not let unquote decorations trick it into thinking numbers are symbols" do
    two = parse(",2").cdr.car
    expect(two.class).to eq 2.class
    expect(two).to eq 2
  end

  it "should not let unquote-splicing decorations trick it into thinking numbers are symbols" do
    two = parse(",@2").cdr.car
    expect(two.class).to eq 2.class
    expect(two).to eq 2
  end

  it "should quote-unquote symbols" do
    expect(parse "',foo").to eq pair_list([quote, pair_list([unquote, foo])])
  end

  it "should unquote-unquote_splicing symbols" do
    expect(parse(",,@foo").inspect).to eq "(unquote (unquote-splicing foo))"
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

  it "retains otherwise unidentified list prefixes" do
    expect(parse "%wong(bar)").to eq pair_list([prefix_list, "%wong", pair_list([bar])])
  end

  it "should do some complicated unquote stuff with lists" do
    expect(parse("`(a b `(c d ,(+ 1 2) ,,(+ 3 4)))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote (+ 1 2)) (unquote (unquote (+ 3 4)))))))"
  end

  it "should do some complicated unquote stuff with mixed lists and symbols" do
    expect(parse("`(a b `(c d ,,@foo e f))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote (unquote-splicing foo)) e f))))"
    expect(parse("`(a b `(c d ,@,foo e f))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote-splicing (unquote foo)) e f))))"
    expect(parse("`(a b `(c d ,',foo e f))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote (quote (unquote foo))) e f))))"
  end

  it "should do some complicated unquote stuff with lists" do
    expect(parse("`(a b `(c d ,(+ 1 2) ,,@(list 3 4)))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote (+ 1 2)) (unquote (unquote-splicing (list 3 4)))))))"
  end

  it "should do some complicated unquote stuff with symbols" do
    expect(parse("`(a b `(c d ,(+ 1 2) ,,x))").inspect).to eq "(quasiquote (a b (quasiquote (c d (unquote (+ 1 2)) (unquote (unquote x))))))"
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

  it "parses a simple string" do
    expect(parse '"foo"').to eq "foo"
  end

  it "parses a string with a simple interpolation" do
    str = "foo "
    empty = ""
    expect(parse '"foo ~foo"').to eq pair_list([string_pieces, str, foo])
  end

  it "parses a string with a more complex interpolation" do
    strf = "foo "
    strb = " bar"
    expect(parse '"foo ~(foo bar) bar"').to eq pair_list([string_pieces, strf, pair_list([foo, bar]), strb])
  end

  it "parses a string with an interpolation containing a nested interpolation" do
    strf = "foo "
    strb = " bar"

    nested = pair_list [string_pieces, strf, foo, strb]
    expr   = pair_list [foo, nested, bar]

    expect(parse '"foo ~(foo "foo ~foo bar" bar) bar"').to eq pair_list([string_pieces, strf, expr, strb])
  end

  it "parses a string with only an interpolation" do
    empty = ""
    expect(parse '"~foo"').to eq foo
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

  it "parses an expression with whitespace before closing paren" do
    txt = <<NYDP
(def plugin-end   (name) (assign this-plugin nil ) (chapter-end))
NYDP
    expect(parse(txt).to_a.inspect).to eq "[def, plugin-end, (name), (assign this-plugin nil), (chapter-end)]"
  end

  it "parses a more complete expression" do
    txt = <<NYDP
(mac def (name args . body)
  ; define a new function in the global namespace
  (chapter nydp-core)
  (define-def-expr name args (filter-forms (build-def-hash (hash)) body)))
NYDP
    parsed = parse(txt).to_a
    expect(parsed[0]).to eq sym("mac")
    expect(parsed[1]).to eq sym("def")
    args = parsed[2].to_a
    expect(args[0]).to eq sym("name")
    expect(args[1]).to eq sym("args")
    expect(args[2]).to be_nil
    expect(parsed[2].cdr.cdr).to eq sym("body")
    expect(parsed[3].to_a).to eq [sym("comment"), "define a new function in the global namespace"]
    expect(parsed[4].to_a).to eq [sym("chapter"), sym("nydp-core")]
  end
end
