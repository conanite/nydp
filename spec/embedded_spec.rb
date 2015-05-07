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

  def parse_string txt, open_delim, close_delim
    reader = Nydp::StringReader.new txt
    Nydp::Parser.new(ns).string(Nydp::Tokeniser.new(reader), open_delim, close_delim)
  end

  it "should parse empty string" do
    expected = pair_list([sym('string-pieces'), Nydp::StringFragmentCloseToken.new('','$%')])
    actual   = parse_string "%", '$', /%/
    expect(actual).to eq ''
  end

  it "should parse external text" do
    actual   = parse_string "a fluffy bunny!", 'EAT ', /!/
    expect(actual)        .to eq "a fluffy bunny"
    expect(actual.inspect).to eq '"a fluffy bunny"'
  end

  it "should parse a string delimited by eof" do
    expected = pair_list([sym('string-pieces'), Nydp::StringFragmentCloseToken.new('a fluffy bunny!','a fluffy bunny!')])
    actual   = parse_string "a fluffy bunny!", '', :eof
    expect(actual)        .to eq "a fluffy bunny!"
    expect(actual.inspect).to eq '"a fluffy bunny!"'
  end

  it "should parse a string with embedded code, delimited by eof" do
    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ',':a fluffy bunny! ~')
    x2 = Nydp::StringAtom.new(x2.string, x2)
    x3 = sym('expr')
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = Nydp::StringAtom.new(x4.string, x4)

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string "a fluffy bunny! ~expr a purple cow!", ':', :eof
    expect(actual).to eq expected
  end

  it "should parse a string with embedded code containing a nested string, delimited by eof" do
    n1 = sym(:foo)
    n2 = sym(:bar)
    n3 = 'an embedded bunny :)'
    n4 = sym(:zop)

    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ','------->a fluffy bunny! ~')
    x2 = Nydp::StringAtom.new(x2.string, x2)
    x3 = pair_list [n1, n2, n3, n4]
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = Nydp::StringAtom.new(x4.string, x4)

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string "a fluffy bunny! ~(foo bar \"an embedded bunny :)\" zop) a purple cow!", '------->', :eof
    expect(actual).to eq expected
  end

  it "should parse a string with embedded code containing a nested string containing more embedded code, delimited by eof" do
    e1 = sym(:describe)
    e2 = sym(:bunny)

    s1 = sym('string-pieces')
    s2 = Nydp::StringFragmentToken.new('a rather ','"a rather ~')
    s2 = Nydp::StringAtom.new(s2.string, s2)
    s3 = pair_list [e1, e2]
    s4 = Nydp::StringFragmentCloseToken.new(' bunny :)',' bunny :)"')
    s4 = Nydp::StringAtom.new(s4.string, s4)

    n1 = sym(:foo)
    n2 = sym(:bar)
    n3 = pair_list [s1, s2, s3, s4]
    n4 = sym(:zop)

    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ','------->a fluffy bunny! ~')
    x2 = Nydp::StringAtom.new(x2.string, x2)
    x3 = pair_list [n1, n2, n3, n4]
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = Nydp::StringAtom.new(x4.string, x4)

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string "a fluffy bunny! ~(foo bar \"a rather ~(describe bunny) bunny :)\" zop) a purple cow!", '------->', :eof
    expect(actual).to eq expected
  end

end
