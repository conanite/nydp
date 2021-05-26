require 'spec_helper'

describe Nydp::Parser do
  # let(:aa)               { Nydp::Symbol.mk :aa,                   ns }
  # let(:a)                { Nydp::Symbol.mk :a,                    ns }
  # let(:b)                { Nydp::Symbol.mk :b,                    ns }
  # let(:c)                { Nydp::Symbol.mk :c,                    ns }
  # let(:d)                { Nydp::Symbol.mk :d,                    ns }
  # let(:zz)               { Nydp::Symbol.mk :zz,                   ns }
  # let(:foo)              { Nydp::Symbol.mk :foo,                  ns }
  # let(:bar)              { Nydp::Symbol.mk :bar,                  ns }
  # let(:zab)              { Nydp::Symbol.mk :zab,                  ns }
  # let(:quote)            { Nydp::Symbol.mk :quote,                ns }
  # let(:quasiquote)       { Nydp::Symbol.mk :quasiquote,           ns }
  # let(:unquote)          { Nydp::Symbol.mk :unquote,              ns }
  # let(:unquote_splicing) { Nydp::Symbol.mk :"unquote-splicing",   ns }
  # let(:comment)          { Nydp::Symbol.mk :comment,              ns }
  # let(:dotsyn)           { Nydp::Symbol.mk :"dot-syntax",         ns }
  # let(:cocosyn)          { Nydp::Symbol.mk :"colon-colon-syntax", ns }
  # let(:colosyn)          { Nydp::Symbol.mk :"colon-syntax",       ns }

  let(:aa)               { :aa                    }
  let(:a)                { :a                     }
  let(:b)                { :b                     }
  let(:c)                { :c                     }
  let(:d)                { :d                     }
  let(:zz)               { :zz                    }
  let(:foo)              { :foo                   }
  let(:bar)              { :bar                   }
  let(:zab)              { :zab                   }
  let(:quote)            { :quote                 }
  let(:quasiquote)       { :quasiquote            }
  let(:unquote)          { :unquote               }
  let(:unquote_splicing) { :"unquote-splicing"    }
  let(:comment)          { :comment               }
  let(:dotsyn)           { :"dot-syntax"          }
  let(:cocosyn)          { :"colon-colon-syntax"  }
  let(:colosyn)          { :"colon-syntax"        }

  def parse_string txt
    reader = Nydp::StringReader.new txt
    Nydp.new_parser(ns).embedded(Nydp.new_tokeniser(reader))
  end

  it "should parse empty string" do
    expected = pair_list([sym('string-pieces'), Nydp::StringFragmentCloseToken.new('','')])
    actual   = parse_string ""
    expect(actual).to eq ''
  end

  it "should parse external text" do
    actual   = parse_string "a fluffy bunny!"
    expect(actual)        .to eq "a fluffy bunny!"
    expect(actual._nydp_inspect).to eq '"a fluffy bunny!"'
  end

  it "should parse a string delimited by eof" do
    expected = pair_list([sym('string-pieces'), Nydp::StringFragmentCloseToken.new('a fluffy bunny!','a fluffy bunny!')])
    actual   = parse_string "a fluffy bunny!"
    expect(actual)        .to eq "a fluffy bunny!"
    expect(actual._nydp_inspect).to eq '"a fluffy bunny!"'
  end

  it "should parse a string with embedded code, delimited by eof" do
    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ','a fluffy bunny! ~')
    x2 = x2.string
    x3 = sym('expr')
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = x4.string

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string "a fluffy bunny! ~expr a purple cow!"
    expect(actual).to eq expected
  end

  it "should parse a string with embedded code containing a nested string, delimited by eof" do
    n1 = sym(:foo)
    n2 = sym(:bar)
    n3 = 'an embedded bunny :)'
    n4 = sym(:zop)

    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ','a fluffy bunny! ~')
    x2 = x2.string
    x3 = pair_list [n1, n2, n3, n4]
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = x4.string

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string 'a fluffy bunny! ~(foo bar "an embedded bunny :)" zop) a purple cow!'
    expect(actual).to eq expected
  end

  it "should parse a string with embedded code containing a nested string containing more embedded code, delimited by eof" do
    e1 = sym(:describe)
    e2 = sym(:bunny)

    s1 = sym('string-pieces')
    s2 = Nydp::StringFragmentToken.new('a rather ','a rather ~')
    s2 = s2.string
    s3 = pair_list [e1, e2]
    s4 = Nydp::StringFragmentCloseToken.new(' bunny :)',' bunny :)"')
    s4 = s4.string

    n1 = sym(:foo)
    n2 = sym(:bar)
    n3 = pair_list [s1, s2, s3, s4]
    n4 = sym(:zop)

    x1 = sym('string-pieces')
    x2 = Nydp::StringFragmentToken.new('a fluffy bunny! ','a fluffy bunny! ~')
    x2 = x2.string
    x3 = pair_list [n1, n2, n3, n4]
    x4 = Nydp::StringFragmentCloseToken.new(' a purple cow!',' a purple cow!')
    x4 = x4.string

    expected = pair_list([x1,x2,x3,x4])
    actual   = parse_string "a fluffy bunny! ~(foo bar \"a rather ~(describe bunny) bunny :)\" zop) a purple cow!"
    expect(actual).to eq expected
  end

  it "parses a string that looks like html with little bits of embedded code in it" do
    parsed = parse_string "<div id='item_~{id}'><label>~{data-label-1}</label> ~{data-content-1}</div>"
    expect(parsed._nydp_inspect).to eq '(string-pieces "<div id=\'item_" (brace-list id) "\'><label>" (brace-list data-label-1) "</label> " (brace-list data-content-1) "</div>")'
  end
end
