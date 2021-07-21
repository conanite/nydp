class Nydp::Builtin::Parse
  include Nydp::Builtin::Base

  def initialize ns
    @ns = ns
    super()
  end

  def builtin_invoke vm, args
    parser = Nydp.new_parser(vm.ns)
    tokens = Nydp.new_tokeniser Nydp::StringReader.new args.car.to_s
    exprs  = []
    while !tokens.finished
      expr = parser.expression(tokens)
      exprs << expr unless expr == nil && tokens.finished
    end
    # vm.push_arg Nydp::Pair.from_list exprs
    Nydp::Pair.from_list exprs
  end

  def builtin_call arg
    parser = Nydp.new_parser(@ns)
    tokens = Nydp.new_tokeniser Nydp::StringReader.new arg.to_s
    exprs  = []
    while !tokens.finished
      expr = parser.expression(tokens)
      exprs << expr unless expr == nil && tokens.finished
    end
    Nydp::Pair.from_list exprs
  end
end
