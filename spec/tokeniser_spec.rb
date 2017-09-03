require "spec_helper"

describe "tokenising" do
  it "should return another stream of tokens" do
    tt = []
      reader = Nydp::StringReader.new "(a b c 1 2 3)"
      t = Nydp::Tokeniser.new reader
      tt = []
      tok = t.next_token
      while tok
        tt << tok
        tok = t.next_token
      end
    expect(tt).to eq [[:left_paren, ""],
                      [:symbol, "a"],
                      [:symbol, "b"],
                      [:symbol, "c"],
                      [:number, 1.0],
                      [:number, 2.0],
                      [:number, 3.0],
                      [:right_paren]]
  end

  it "should return a stream of tokens, including whitespace before right-paren" do
    reader = Nydp::StringReader.new "foo )"
    t = Nydp::Tokeniser.new reader
    tt = []
    tok = t.next_token
    while tok
      tt << tok
      tok = t.next_token
    end
    expect(tt).to eq [[:symbol     , "foo"],
                      [:right_paren]]
  end

  it "returns nothing at all" do
    s = Nydp::StringReader.new ""
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to be_nil
  end

  it "returns a whitespace token" do
    s = Nydp::StringReader.new "  "
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to be_nil
  end

  it "returns a symbol token" do
    s = Nydp::StringReader.new "hello"
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:symbol, "hello"]
    expect(tkz.next_token).to be_nil
  end

  it "returns symbol then whitespace" do
    s = Nydp::StringReader.new "hello  "
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:symbol, "hello"]
    expect(tkz.next_token).to be_nil
  end

  it "returns whitespace symbol whitespace symbol whitespace" do
    s = Nydp::StringReader.new " hello world "
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:symbol, "hello"]
    expect(tkz.next_token).to eq [:symbol, "world"]
    expect(tkz.next_token).to be_nil
  end

  it "returns whitespace left_paren symbol whitespace symbol right_paren whitespace" do
    s = Nydp::StringReader.new " (hello world) "
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:left_paren, ""]
    expect(tkz.next_token).to eq [:symbol, "hello"]
    expect(tkz.next_token).to eq [:symbol, "world"]
    expect(tkz.next_token).to eq [:right_paren]
    expect(tkz.next_token).to be_nil
  end

  it "returns whitespace left_paren with prefix symbol whitespace symbol right_paren whitespace" do
    s = Nydp::StringReader.new " %w(hello world) "
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:left_paren, "%w"]
    expect(tkz.next_token).to eq [:symbol, "hello"]
    expect(tkz.next_token).to eq [:symbol, "world"]
    expect(tkz.next_token).to eq [:right_paren]
    expect(tkz.next_token).to be_nil
  end

  it "returns a comment" do
    s = Nydp::StringReader.new "hello
; observe!
world"
    tkz = Nydp::Tokeniser.new s
    expect(tkz.next_token).to eq [:symbol        , 'hello']
    expect(tkz.next_token).to eq [:comment       , "observe!"  ]
    expect(tkz.next_token).to eq [:symbol        , "world"]
    expect(tkz.next_token).to be_nil
  end
end
