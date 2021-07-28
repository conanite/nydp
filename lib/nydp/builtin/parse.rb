class Nydp::Builtin::Parse
  include Nydp::Builtin::Base, Singleton

  def builtin_call arg
    parser = Nydp.new_parser
    tokens = Nydp.new_tokeniser Nydp::StringReader.new arg.to_s
    exprs  = []
    while !tokens.finished
      expr = parser.expression(tokens)
      exprs << expr unless expr == nil && tokens.finished
    end
    Nydp::Pair.from_list exprs
  end
end
